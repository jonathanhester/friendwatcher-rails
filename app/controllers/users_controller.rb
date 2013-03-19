class UsersController < ApplicationController

  def create
    fbid = params[:fbid]
    token = params[:token]
    user = User.validate_user(fbid, token)
    if user
      render :inline => "1"
      Rails.logger.info "User validated #{user_url(user, id: fbid, token: token)}"
    else
      Rails.logger.info "User invalid #{user_url(user, id: fbid, token: token)}"
      render :inline => "0"
    end
  end

  def show
    @user = User.verify(params[:id], params[:token])
    render json: { status: :invalid } and return if !@user
    respond_to do |format|
      format.html
      format.json do
        json = @user.to_json(params[:page], params[:per])
        render json: JSON.pretty_generate(json)
      end
    end
  end

  def verify_token
    @user = User.verify(params[:id], params[:token])
    if @user && !@user.token_invalid
      Rails.logger.info "User#verify_token success #{params[:id]}, #{params[:token]}"
      render :inline => "1"
    else
      Rails.logger.info "User#verify_token failure #{params[:id]}, #{params[:token]}"
      render :inline => "0"
    end
  end

  def force_refresh
    @user = User.verify(params[:id], params[:token])
    Rails.logger.info "User#force_refresh #{params[:id]}, #{params[:token]}"
    if @user
      response = @user.force_refresh
      render :inline => "1"
    else
      render :inline => "0"
    end
  end

  def test_push
    @user = User.verify(params[:id], params[:token])
    Rails.logger.info "User#test_push #{@user.try(:id)}, #{params[:token]}"
    if @user
      response = @user.test_push
      render :inline => "1" if response[:status] == 200
      render :inline => "1" if response[:status] != 200
    else
      render :inline => "0"
    end
  end

end
