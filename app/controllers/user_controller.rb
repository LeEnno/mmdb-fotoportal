class UserController < ApplicationController
  def login
    if !params[:user].blank?
      params[:user].reject!{ |key, val| key == "password_confirmation" }
      
      @user = User.new(params[:user])
      if @user.valid?
        @user.save
        # redirect somewhere
      end

      puts "huhu"
      puts @user.errors.inspect
    end
  end

  def register
  end

  def logout
  end
end
