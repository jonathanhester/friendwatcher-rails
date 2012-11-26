class DevicesController < ApplicationController

  def create
    fbid = params[:fbid]
    token = params[:token]
    if User.verify(fbid, token)
      user = User.where(fbid: fbid).first_or_create
      user.token = token
      if user.save!
        device = user.devices.where(device_id: params[:device_id]).first_or_create
        device.registration_id = params[:registrationId]
        if device.save
          render :inline => user.id
        end
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
