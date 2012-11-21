class User < ActiveRecord::Base
  has_many :friends

  def self.receive_update(uid)
    Rails.logger.info "Receive update #{uid}"
  end

  def fetch_friends

  end

  def notify_user

  end
end
