class UsersController < ApplicationController

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
    render json: { status: :invalid } and return if !@user
    respond_to do |format|
      format.html
      format.json { render json: JSON.pretty_generate(@user.to_json) }
    end
  end

  def verify_token
    @user = User.verify(params[:id], params[:token])
    if @user && !@user.token_invalid
      render :inline => "1"
    else
      render :inline => "0"
    end
  end

  def force_refresh
    @user = User.verify(params[:id], params[:token])
    if @user
      response = @user.force_refresh
      render :inline => "1"
    else
      render :inline => "0"
    end
  end

  def test_push
    @user = User.verify(params[:id], params[:token])
    if @user
      response = @user.test_push
      render :inline => "1" if response[:status] == 200
      render :inline => "1" if response[:status] != 200
    else
      render :inline => "0"
    end
  end

end
