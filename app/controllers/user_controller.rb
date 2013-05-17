class UserController < ApplicationController

  before_filter :redirect_if_authenticated, :only => [:login, :register]
  
  def login
    return if params[:user].blank?

    @user = User.find_by_email_and_password(
      params[:user][:email],
      params[:user][:password]
    )

    if @user.nil?
      flash[:error] = 'falsche Zugangsdaten'
    else
      create_session_and_redirect
    end
  end


  def register
    return if params[:user].blank?
    @user = User.new(params[:user])

    if @user.valid?
      @user.save
      create_session_and_redirect
    end
  end

  
  def logout
    Session.delete(session[:id])
  end


  # PRIVATE METHODS
  # ------------------------------------------------------------------------------  
  private

  def create_session_and_redirect
    session[:id] = Session.create(:user => @user).id
    redirect_to_gallery
  end

  def redirect_to_gallery
    redirect_to gallery_path
  end

  def redirect_if_authenticated
    redirect_to_gallery if @is_logged_in
  end
end
