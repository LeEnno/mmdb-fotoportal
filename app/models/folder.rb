class Folder < ActiveRecord::Base
  attr_accessible :name, :user

  belongs_to :user
  belongs_to :parent, :class_name => 'Folder', :foreign_key => 'parent_id'
  has_many :children, :class_name => 'Folder', :foreign_key => 'parent_id'
  has_many :pictures, :dependent => :destroy

  def all_pictures
    pics = self.pictures
    self.children.each do |f|
      pics += f.all_pictures
    end
    pics
  end


  def children_ids
    ids = [id]
    self.children.each do |f|
      ids += f.children_ids
    end
    ids
  end
end
