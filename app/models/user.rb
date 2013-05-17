class User < ActiveRecord::Base
  attr_accessible :email, :firstname, :password, :surname

  has_many :sessions
  has_many :folders
  has_many :pictures, :through => :folders

  validates_presence_of :firstname, :surname, :email, :password_confirmation
  validates_confirmation_of :password
end
