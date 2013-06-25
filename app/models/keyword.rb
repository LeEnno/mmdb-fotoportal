class Keyword < ActiveRecord::Base
  attr_accessible :name

  has_many :keywords_pictures, :dependent => :destroy
  has_many :pictures, :through => :keywords_pictures
end
