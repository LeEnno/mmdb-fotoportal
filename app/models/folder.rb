class Folder < ActiveRecord::Base
  attr_accessible :name, :user

  belongs_to :user
  belongs_to :parent, :class_name => 'Folder', :foreign_key => 'parent_id'
  has_many :children, :class_name => 'Folder', :foreign_key => 'parent_id'
  has_many :pictures
end
