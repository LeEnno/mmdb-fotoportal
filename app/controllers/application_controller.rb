class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_login_status

  def redirect_if_not_authenticated
    if !@is_logged_in
      flash[:error] = 'nicht eingeloggt'
      redirect_to :root
    end
  end

  private
  def set_login_status
    if @is_logged_in.nil?
      @is_logged_in = false

      if !session[:id].blank? && Session.exists?(session[:id])
        sess = Session.find(session[:id])
        if sess.expires_at > Time.now
          sess.refresh
          @is_logged_in = true
          @user         = sess.user
        else
          sess.delete
        end
      end
    end
  end
end
