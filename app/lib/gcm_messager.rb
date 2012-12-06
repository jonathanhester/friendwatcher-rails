class GcmMessager
  def self.lost_friends(registration_ids)
    message = "Your friends list has changed!"

    gcm = GCM.new(APP_CONFIG['gcm_api_key'])

    options = {data: {message: message}, collapse_key: "updated_list"}
    response = gcm.send_notification(registration_ids, options)
  end
end