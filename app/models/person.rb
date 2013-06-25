class Person < ActiveRecord::Base
  attr_accessible :name

  has_many :appearances, :dependent => :destroy
  has_many :pictures, :through => :appearances
end
