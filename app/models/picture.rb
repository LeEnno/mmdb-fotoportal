class Picture < ActiveRecord::Base
  attr_accessible :altitude, :aperture, :camera, :color_depth, :color_space, :exposure_time, :filesize, :focal_length, :has_flash, :hash, :height, :iso, :location, :longitude, :mean_black, :mean_blue, :mean_brown, :mean_cyan, :mean_green, :mean_magenta, :mean_orange, :mean_red, :mean_violet, :mean_white, :mean_yellow, :taken_at, :title, :width

  belongs_to :folder
  has_and_belongs_to_many :persons
  has_and_belongs_to_many :keywords
end
