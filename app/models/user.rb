class User < ActiveRecord::Base
  attr_accessible :email, :firstname, :password, :surname

  has_many :sessions
  has_many :folders
  has_many :pictures, :through => :folders
end
