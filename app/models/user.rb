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
#  name               :string(255)
#

class User < ActiveRecord::Base
  has_many :friends, :dependent => :destroy
  has_many :friend_events, :dependent => :destroy
  has_many :devices, :dependent => :destroy

  def self.verify(fbid, token)
    User.where(fbid: fbid, token: token).first
  end

  def self.validate_user(fbid, token)
    begin
      fb_user = fetch_user("me", token)
    rescue
      fb_user = nil
    end
    if fb_user.present?
      user = User.where(fbid: fbid).first_or_create
      user.token = token
      user.name = fb_user['name']
      user.token_invalid = false
      user.save!
      user.reload_friends(true)
      return user
    end
    false
  end

  def to_json(page = nil, per = nil)
    page ||= 1
    per ||= 20
    status = :current
    meta = {
        name: self.name,
        total: friends.current.count,
        synced: last_synced,
        created: created_at,
        removed: friend_events.removed.count,
    }

    events = []
    friend_events_rel = friend_events.page(page).per(per).order('created_at desc')
    friend_events_rel.each do |friend_event|
      friend_data = {
          name: friend_event.name,
          link: "http://www.facebook.com/profile.php?id=#{friend_event.fbid}",
          time: friend_event.updated_at,
          event_type: friend_event.event
      }
      events << friend_data
    end

    data = {
        events: events
    }

    result = {
        isLast: friend_events_rel.num_pages <= page.to_i,
        status: status,
        data: data
    }
    result[:meta] = meta if page.present? && page.to_i == 1
    result
  end

  def receive_update
    Rails.logger.info "Receive update #{self.fbid}"
    begin
      (added, removed) = self.reload_friends_without_delay
      response = GcmMessager.friends_changed(registration_ids, added, removed, self)
    rescue
      response = GcmMessager.invalid_token(registration_ids)
    end
    response
  end
  handle_asynchronously :receive_update

  def force_refresh
    Rails.logger.info "Force refresh #{self.fbid}"
    begin
      self.reload_friends_without_delay
      response = GcmMessager.force_refresh(registration_ids)
    rescue
      response = GcmMessager.invalid_token(registration_ids)
    end
    response
  end
  handle_asynchronously :force_refresh

  def registration_ids
    devices.map(&:registration_id)
  end

  def test_push
    response = GcmMessager.test_push(registration_ids)
    response
  end

  def reload_friends(initial = false)
    added_friends = []
    removed_friends = []
    self.update_attribute :last_synced, Time.now
    begin
      response = fetch_friends(self.fbid, self.token)
    rescue
      self.token_invalid = true
      self.token_invalid_date = Time.now
      self.save
      raise
    end
    friends = {}
    response.each do |friend|
      friends[friend['id']] = friend
    end
    current_friends = {}
    self.friends.current.each do |current_friend|
      fbid = current_friend.fbid
      current_friends[fbid.to_s] = current_friend
      if !friends[fbid]
        removed_friends << add_removed_friend(current_friend)
      end
    end

    friends.each do |fbid, friend|
      if !current_friends[fbid]
        new_friend = self.friends.where(fbid: fbid).first_or_create
        should_add_friend_event = (new_friend.status != :disabled && !initial)
        new_friend.fbid = fbid.to_s
        new_friend.status_modified_date = Time.now
        new_friend.status = :current
        new_friend.name = friend['name']
        new_friend.save!
        if should_add_friend_event
          added_friends << add_added_friend(new_friend)
        end
      end
    end
    Rails.logger.info "Receive update friends (#{friends.count})"
    GcmMessager.initial_push(registration_ids) if initial
    return [added_friends.compact, removed_friends.compact]
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
    friends
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
      friend_event
    rescue
      friend.status = :disabled
      friend.status_modified_date = Time.now
      friend.save
    end
  end

  def add_added_friend(friend)
    friend_event = self.friend_events.create
    friend_event.fbid = friend.fbid
    friend_event.name = friend.name
    friend_event.event = :added
    friend_event.save
    friend_event
  end
end
