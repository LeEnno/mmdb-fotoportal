class KeywordsPicture < ActiveRecord::Base
  attr_accessible :keyword_id, :picture_id

  belongs_to :keyword
  belongs_to :picture
end
