class Picture < ActiveRecord::Base
  attr_accessible :aperture, :camera, :color_depth, :color_space, :exposure_time, :filename, :filesize, :focal_length, :folder, :has_flash, :height, :iso, :latitude, :location, :longitude, :mean_black, :mean_blue, :mean_brown, :mean_cyan, :mean_green, :mean_magenta, :mean_orange, :mean_red, :mean_violet, :mean_white, :mean_yellow, :path_hash, :taken_at, :title, :width

  belongs_to :folder
  has_and_belongs_to_many :persons, :join_table => 'appearances'
  has_and_belongs_to_many :keywords
  # should semantically be `belongs_to`, but `:through` wouldn't work
  has_one :user, :through => :folder

  after_initialize :_set_location_fields, :if => :new_record?
  after_create     :_make_scales


  # CONSTANTS
  # ----------------------------------------------------------------------------
  
  FILE_NAME_ORIG   = {:name => 'original'}
  FILE_NAME_MEDIUM = {:name => 'medium',    :x => 640, :y => 480}
  FILE_NAME_THUMB  = {:name => 'thumbnail', :x => 100, :y => 100}


  # PUBLIC METHODS
  # ----------------------------------------------------------------------------
  
  def file_path(scale = nil)
    Rails.root.join('public', _file_path_from_public(scale))
  end


  def file_url(scale = nil)
    '/' + _file_path_from_public(scale)
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
        self.camera        = exif_data.model              unless exif_data.model.nil?
        self.taken_at      = exif_data.date_time          unless exif_data.date_time.nil?
        self.exposure_time = exif_data.exposure_time.to_f unless exif_data.exposure_time.nil? # must be int
        self.aperture      = exif_data.f_number.to_s      unless exif_data.f_number.nil? # must be string

        self.latitude      = exif_data.gps.latitude       unless exif_data.gps.nil?
        self.longitude     = exif_data.gps.longitude      unless exif_data.gps.nil?
        # TODO location with Google-API

        self.iso          = exif_data.iso_speed_ratings   if exif_data.respond_to?('iso_speed_ratings')
        self.color_space  = exif_data.color_space.to_s    if exif_data.respond_to?('color_space')
        self.focal_length = exif_data.focal_length.to_f   if exif_data.respond_to?('focal_length')
        self.has_flash    = !!exif_data.flash             if exif_data.respond_to?('flash')
      end
    end

    # TODO color means by David
  end


  # get all persons in printable format
  def persons_as_string
    persons.pluck(:name).join(', ')
  end


  # get all keywords in printable format
  def keywords_as_string
    keywords.pluck(:name).join(', ')
  end


  # do we have to detect faces or did we already do that in the past?
  # 
  # We assume that faces have already been detected if the picture has been
  # updated with metadata (like faces, folders or keywords) after creation.
  # 
  def facedetect?
    self.persons.count === 0 && self.updated_at == self.created_at
  end


  # PRIVATE METHODS
  # ----------------------------------------------------------------------------
  private

  def _set_location_fields
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


  def _file_path_from_public(scale)
    [
      'uploads',
      path_hash.gsub(/(\w|\d)(\w|\d)([\w\d]{30})/, '\1/\2/\3'), # converts '123456' to '1/2/3456'
      _scale_to_filename(scale)
    ].join('/')
  end


  def _scale_to_filename(scale)
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

    filename + '.' + extension
  end


  def _make_scales
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
