# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  fbid               :string(255)
#  token              :string(255)
#  token_invalid_date :datetime
#  token_invalid      :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  last_synced        :datetime
#

class User < ActiveRecord::Base
  has_many :friends
  has_many :friend_events
  has_many :devices

  def self.verify(fbid, token)
    User.where(fbid: fbid, token: token).first
  end

  def self.validate_user(fbid, token)
    begin
      fb_user = fetch_user("me", token)
    rescue  Exception => exc
      fb_user = nil
    end
    if fb_user
      user = User.where(fbid: fbid).first_or_create
      user.token = token
      user.save!
      user.reload_friends
      return user
    end
    false
  end

  def to_json
    if self.last_synced.nil?
      status = :updating
      meta = {
          total: "Updating...",
          synced: "Syncing now...",
          created: created_at,
          removed: 0,
      }
      data = {
          removed: []
      }
    else
      status = :current
      meta = {
         total: friends.current.count,
         synced: last_synced,
         created: created_at,
         removed: friend_events.removed.count,
      }

      removed = []
      friend_events.removed.each do |friend_event|
        friend_data = {
            name: friend_event.name,
            link: "http://www.facebook.com/profile.php?id=#{friend_event.fbid}",
            time: friend_event.updated_at
        }
        removed << friend_data
      end

      data = {
          removed: removed
      }
    end

    {
        status: status,
        meta: meta,
        data: data
    }
  end

  def receive_update
    Rails.logger.info "Receive update #{self.fbid}"
    self.reload_friends_without_delay
    registration_ids= devices.map(&:registration_id)
    GcmMessager.lost_friends(registration_ids)
  end
  handle_asynchronously :receive_update

  def reload_friends
    self.update_attribute :last_synced, Time.now
    response = fetch_friends(self.fbid, self.token)
    friends = {}
    response.each do |friend|
      friends[friend['id']] = friend
    end
    current_friends = {}
    self.friends.current.each do |current_friend|
      fbid = current_friend.fbid
      current_friends[fbid.to_s] = current_friend
      if !friends[fbid]
        add_removed_friend(current_friend)
      end
    end

    friends.each do |fbid, friend|
      if !current_friends[fbid]
        new_friend = self.friends.where(fbid: fbid).first_or_create
        new_friend.fbid = fbid.to_s
        new_friend.status_modified_date = Time.now
        new_friend.status = :current
        new_friend.name = friend['name']
        new_friend.save!
      end
    end

    Rails.logger.info "Receive update #{friends}"
  end
  handle_asynchronously :reload_friends

  def self.fetch_user(fbid, token)
    @graph = Koala::Facebook::API.new(token)
    profile = @graph.get_object(fbid)
    profile
  end

  private
  def fetch_friends(fbid, token)
    @graph = Koala::Facebook::API.new(token)
    friends = @graph.get_object("me/friends")
  end

  def add_removed_friend(friend)
    begin
      fb_response = User.fetch_user(friend.fbid, self.token)
      friend_event = self.friend_events.create
      friend_event.fbid = friend.fbid
      friend_event.name = friend.name
      friend_event.event = :removed
      friend_event.save
      friend.delete
    rescue Exception => exc
      friend.status = :disabled
      friend.status_modified_date = Time.now
      friend.save
    end
  end
end
