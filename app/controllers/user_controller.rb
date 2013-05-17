class UserController < ApplicationController
  def login
    
  end

  def register
    if !params[:user].blank?
      @user = User.new(params[:user])

      if @user.valid?
        @user.save
        create_session_and_redirect
      end
    end
  end

  def logout
  end

  private
  def create_session_and_redirect
    session[:id] = Session.create(:user => @user).id
    redirect_to gallery_path
  end
end
