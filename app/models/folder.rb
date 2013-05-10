class Folder < ActiveRecord::Base
  attr_accessible :name

  belongs_to :user
  belongs_to :parent, :class_name => 'Folder'
  has_many :children, :class_name => 'Folder'
  has_many :pictures
end
