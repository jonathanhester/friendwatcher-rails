class User < ActiveRecord::Base
  has_many :friends
  has_many :devices

  def self.verify(fbid, token)
    User.where(fbid: fbid, token: token).first
  end

  def self.validate_user(fbid, token)
    fb_user = fetch_user(fbid, token)
    if fb_user
      user = User.where(fbid: fbid).first_or_create
      user.token = token
      user.save!
    end
  end


  def receive_update
    Rails.logger.info "Receive update #{self.fbid}"
    self.delay.fetch_friends
  end

  def fetch_friends
    Rails.logger.info "Fetching friends #{self.fbid}"
  end

  def notify_user
    Rails.logger.info "Notifying user of update #{self.fbid}"
  end

  private
  def self.fetch_user(fbid, token)
    @graph = Koala::Facebook::API.new(token)
    profile = @graph.get_object("me")
    profile
  end
end
