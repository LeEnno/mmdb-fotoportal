class Picture < ActiveRecord::Base
  attr_accessible :aperture, :camera, :color_depth, :color_space, :exposure_time, :filename, :filesize, :focal_length, :folder, :has_flash, :height, :iso, :latitude, :location, :longitude, :mean_black, :mean_blue, :mean_brown, :mean_cyan, :mean_green, :mean_magenta, :mean_orange, :mean_red, :mean_violet, :mean_white, :mean_yellow, :path_hash, :taken_at, :title, :width

  belongs_to :folder
  has_and_belongs_to_many :persons
  has_and_belongs_to_many :keywords

  after_initialize :set_location_fields, :if => :new_record?
  after_create     :make_scales


  # CONSTANTS
  # ----------------------------------------------------------------------------
  
  FILE_NAME_ORIG   = {:name => 'original'}
  FILE_NAME_MEDIUM = {:name => 'medium',    :x => 640, :y => 480}
  FILE_NAME_THUMB  = {:name => 'thumbnail', :x => 100, :y => 100}


  # PUBLIC METHODS
  # ----------------------------------------------------------------------------
  
  def file_path(scale = nil)
    Rails.root.join('public', file_path_from_public(scale))
  end


  def file_url(scale = nil)
    '/' + file_path_from_public(scale)
  end


  # extract data from ImageMagick and EXIF-data
  def extract_metadata
    image_path = file_path('original').to_s

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

    # fetch extension
    self.extension = title.gsub(/.*\.(\w+)$/, '\1')

    # create directory for image
    require 'fileutils'
    FileUtils.mkpath(file_path)
  end


  def file_path_from_public(scale)
    [
      'uploads',
      path_hash.gsub(/([\w\d]{30})(\w|\d)(\w|\d)/, '\1/\2/\3'), # converts '123456' to '1234/5/6'
      scale_to_filename(scale)
    ].join('/')
  end


  def scale_to_filename(scale)
    return '' if scale.nil?

    filename = ''

    case scale
      when 'thumb'
        filename = FILE_NAME_THUMB[:name]
      when 'medium'
        filename = FILE_NAME_MEDIUM[:name]
      when 'original'
        filename = FILE_NAME_ORIG[:name]
      else
        raise "invalid scale param: #{scale}"
    end

    filename + "." + extension
  end


  def make_scales
    require 'RMagick'
    im_orig = Magick::Image::read(file_path('original')).first

    target_directory = file_path

    im_thumb = im_orig.resize_to_fill(FILE_NAME_THUMB[:x], FILE_NAME_THUMB[:y])
    im_thumb.write(target_directory.join(FILE_NAME_THUMB[:name] + '.' + extension))

    if im_orig.columns > FILE_NAME_MEDIUM[:x] || im_orig.rows > FILE_NAME_MEDIUM[:y]
      im_medium = im_orig.resize_to_fit(FILE_NAME_MEDIUM[:x], FILE_NAME_MEDIUM[:y])
    else
      im_medium = im_orig
    end
    im_medium.write(target_directory.join(FILE_NAME_MEDIUM[:name] + '.' + extension))
  end
end
