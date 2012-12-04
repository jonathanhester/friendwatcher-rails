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

  def show
    @user = User.verify(params[:id], params[:token])
  end

  def update
    Rails.logger.info "create"
  end

  def verify_token
    user = User.where(fbid: params[:id]).first
    if user && user.token == params[:token]
      render :inline => "1"
    else
      render :inline => "0"
    end
  end

end
