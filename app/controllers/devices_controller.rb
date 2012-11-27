class DevicesController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def create
    fbid = params[:user_id]
    token = params[:token]
    if user = User.verify(fbid, token)
      device = user.devices.where(device_id: params[:device_id]).first_or_create
      device.registration_id = params[:registrationId]
      if device.save
        render :inline => "1"
      end
    end
    render :inline => "0"
    Rails.logger.info "create"
  end

  def delete
    Rails.logger.info "delete"
  end

  def update
    Rails.logger.info "update"
  end
end
