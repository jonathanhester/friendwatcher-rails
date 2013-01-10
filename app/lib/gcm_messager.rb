class GcmMessager
  def self.friends_changed(registration_ids, added, removed)
    message = "Your friends list has changed!"

    gcm = GCM.new(APP_CONFIG['gcm_api_key'])

    options = {data: {message: message, type: :rtu}, collapse_key: "updated_list"}

    if (added.count > 0 || removed.count > 0 || user.fbid == "3624241")
      response = gcm.send_notification(registration_ids, options)
    end
  end

  def self.force_refresh(registration_ids)
    message = "Your friends list has been reloaded!"

    gcm = GCM.new(APP_CONFIG['gcm_api_key'])

    options = {data: {message: message, type: :force_refresh}, collapse_key: "refreshed"}
    response = gcm.send_notification(registration_ids, options)
  end

  def self.test_push(registration_ids)
    message = "Push notifications are working!"

    gcm = GCM.new(APP_CONFIG['gcm_api_key'])

    options = {data: {message: message, type: :test}, collapse_key: "test"}
    response = gcm.send_notification(registration_ids, options)
  end

  def self.initial_push(registration_ids)
    message = "Your friends list is being monitored!"

    gcm = GCM.new(APP_CONFIG['gcm_api_key'])

    options = {data: {message: message, type: :test}, collapse_key: "test"}
    response = gcm.send_notification(registration_ids, options)
  end
end