class User < ActiveRecord::Base
  has_many :friends
  has_many :devices

  def self.verify(fbid, token)
    return true
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
end
