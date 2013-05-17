class Session < ActiveRecord::Base
  attr_accessible :expires_at, :user

  belongs_to :user

  before_create :set_expiration

  SESSION_LENGTH = 30

  def refresh
    set_expiration
  end

  private
  def set_expiration
    self.expires_at = Time.now + SESSION_LENGTH.minutes
  end
end
