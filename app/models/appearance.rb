class Appearance < ActiveRecord::Base
  # attr_accessible :person_id, :picture_id

  belongs_to :picture
  belongs_to :person
end
