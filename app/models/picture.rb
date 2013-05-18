class Picture < ActiveRecord::Base
  attr_accessible :aperture, :camera, :color_depth, :color_space, :exposure_time, :filename, :filesize, :focal_length, :folder, :has_flash, :height, :iso, :latitude, :location, :longitude, :mean_black, :mean_blue, :mean_brown, :mean_cyan, :mean_green, :mean_magenta, :mean_orange, :mean_red, :mean_violet, :mean_white, :mean_yellow, :path_hash, :taken_at, :title, :width

  belongs_to :folder
  has_and_belongs_to_many :persons
  has_and_belongs_to_many :keywords

  after_initialize :set_location_fields, :if => :new_record?


  # CONSTANTS
  # ----------------------------------------------------------------------------
  
  FILE_NAME_BASE = 'original'


  # PUBLIC METHODS
  # ----------------------------------------------------------------------------
  
  def file_path(include_filename = true)
    Rails.root.join(
      'public',
      'uploads',
      path_hash.gsub(/([\w\d]{30})(\w|\d)(\w|\d)/, '\1/\2/\3'), # converts '123456' to '1234/5/6'
      include_filename ? filename : ''
    )
  end


  # extract data from ImageMagick and EXIF-data
  def extract_metadata
    image_path = file_path.to_s

    # ImageMagick
    require 'RMagick'
    img              = Magick::Image::read(image_path).first
    format           = img.format
    self.width       = img.columns
    self.height      = img.rows
    self.filesize    = img.filesize
    self.color_depth = img.depth

    # exif
    if format == 'JPEG'
      exif_data = EXIFR::JPEG.new(image_path)
      if exif_data.exif?
        self.camera        = exif_data.model unless exif_data.model.nil?
        self.taken_at      = exif_data.date_time unless exif_data.date_time.nil?
        self.exposure_time = exif_data.exposure_time.to_f unless exif_data.exposure_time.nil? # must be int
        self.aperture      = exif_data.f_number.to_s unless exif_data.f_number.nil? # TODO must be string
        self.latitude      = exif_data.gps.latitude unless exif_data.gps.nil?
        self.longitude     = exif_data.gps.longitude unless exif_data.gps.nil?
        # TODO location with Google-API

        self.iso          = exif_data.iso_speed_ratings if exif_data.respond_to?('iso_speed_ratings')
        self.color_space  = exif_data.color_space.to_s if exif_data.respond_to?('color_space')
        self.focal_length = exif_data.focal_length.to_f if exif_data.respond_to?('focal_length')
        self.has_flash    = !!exif_data.flash if exif_data.respond_to?('flash')
      end
    end

    # TODO color means by David
  end


  # PRIVATE METHODS
  # ----------------------------------------------------------------------------
  private

  def set_location_fields
    # set hash in db
    require 'digest/md5'
    begin
      self.path_hash = Digest::MD5.hexdigest((Time.now.to_i + rand(1..99)).to_s)
    end while Picture.find_by_path_hash(self.path_hash)

    # create directory for image
    require 'fileutils'
    FileUtils.mkpath(file_path(false)) 

    # replace original filename by our FILE_NAME_BASE
    self.filename = title.gsub(/.*\.(\w+)$/, FILE_NAME_BASE + '.\1')
  end
end
