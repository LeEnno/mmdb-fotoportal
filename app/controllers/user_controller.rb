class UserController < ApplicationController

  before_filter :_redirect_if_authenticated, :only => [:login, :register]
  

  def login
    return if params[:user].blank?

    @user = User.find_by_email_and_password(
      params[:user][:email],
      params[:user][:password]
    )

    if @user.nil?
      flash[:error] = 'falsche Zugangsdaten'
    else
      _create_session_and_redirect
    end
  end


  def register
    return if params[:user].blank?
    @user = User.new(params[:user])

    if @user.valid?
      @user.save
      Folder.create(:user => @user, :name => 'Alle Fotos')
      _create_session_and_redirect
    end
  end

  
  def logout
    Session.delete(session[:id])
    flash[:notice] = 'erfolgreich ausgeloggt'
    redirect_to login_path
  end


  # PRIVATE METHODS
  # ------------------------------------------------------------------------------  
  private

  def _create_session_and_redirect
    session[:id] = Session.create(:user => @user).id
    redirect_to gallery_path
  end

  def _redirect_if_authenticated
    redirect_to gallery_path if @is_logged_in
  end
end
