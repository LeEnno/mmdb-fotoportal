class Person < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :pictures, :join_table => 'appearances'
end
