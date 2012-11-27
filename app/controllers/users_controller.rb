class UsersController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def create
    fbid = params[:fbid]
    token = params[:token]
    user = User.validate_user(fbid, token)
    if user
      render :inline => "1"
    else
      render :inline => "0"
    end
  end

  def show(id)
    Rails.logger.info "create"
  end

  def update(id)
    Rails.logger.info "create"
  end

  def verify_token(id)
    Rails.logger.info "create"
  end

end
