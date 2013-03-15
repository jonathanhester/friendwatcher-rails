class FacebookController < ApplicationController

  def rtu
    if(realtime_request?(request))
      case request.method
        when "GET"
          challenge = Koala::Facebook::RealtimeUpdates.meet_challenge(params,'asdf')
          if(challenge)
            render :text => challenge
          else
            render :text => 'Failed to authorize facebook challenge request'
          end
        when "POST"
          req = ActiveSupport::JSON.decode(request.body)
          req['entry'].each do |entry|
            uid = entry['uid']
            user = User.find_by_fbid(uid)
            user.try(:receive_update)
          end
          render :text => 'Thanks for the update.'
      end
    end
  end

  private

  def realtime_request?(request)
    ((request.method == "GET" && params['hub.mode'].present?) ||
        (request.method == "POST" && request.headers['X-Hub-Signature'].present?))
  end

end
