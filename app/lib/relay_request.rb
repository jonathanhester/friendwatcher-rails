class RelayRequest
  def self.relay_request(req)
    url = "http://fbfriendswatcher.appspot.com/fbupdate"

    response = HTTParty.post(url, {
        body: req.to_json,
        headers: {"X-Hub-Signature" => "123"}
    })
    puts response
    response
  end

end