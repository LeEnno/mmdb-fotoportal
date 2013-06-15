class Session < ActiveRecord::Base
  attr_accessible :expires_at, :user

  belongs_to :user

  before_create :_set_expiration

  SESSION_LENGTH = 60

  def refresh
    _set_expiration
  end

  private
  def _set_expiration
    self.expires_at = Time.now + SESSION_LENGTH.minutes
  end
end
