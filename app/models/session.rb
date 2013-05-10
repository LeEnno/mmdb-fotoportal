class Session < ActiveRecord::Base
  attr_accessible :expires_at

  belongs_to :user
end
