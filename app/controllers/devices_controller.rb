class DevicesController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def create
    fbid = params[:user_id]
    token = params[:token]
    if user = User.verify(fbid, token)
      device = user.devices.where(device_id: params[:deviceId]).first_or_create
      device.registration_id = params[:deviceRegistrationId]
      if device.save
        render :inline => "1"
      else
        render :inline => "0"
      end
    else
      render :inline => "0"
    end

    Rails.logger.info "create"
  end

  def delete
    Rails.logger.info "delete"
  end

  def update
    Rails.logger.info "update"
  end
end
