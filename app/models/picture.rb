class Picture < ActiveRecord::Base
  attr_accessible :aperture, :camera, :color_depth, :color_space, :exposure_time, :filename, :filesize, :focal_length, :folder, :has_flash, :height, :iso, :latitude, :location, :longitude, :mean_black, :mean_blue, :mean_brown, :mean_cyan, :mean_green, :mean_magenta, :mean_orange, :mean_red, :mean_violet, :mean_white, :mean_yellow, :path_hash, :taken_at, :title, :width

  belongs_to :folder
  has_many :appearances, :dependent => :destroy
  has_many :persons, :through => :appearances

  has_many :keywords_pictures, :dependent => :destroy
  has_many :keywords, :through => :keywords_pictures
  
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
    _save_color_means(img)
    
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


  def _save_color_means(img)
    self.mean_red     = 0
    self.mean_yellow  = 0
    self.mean_orange  = 0
    self.mean_green   = 0
    self.mean_cyan    = 0
    self.mean_blue    = 0
    self.mean_violet  = 0
    self.mean_magenta = 0
    self.mean_white   = 0
    self.mean_black   = 0
    self.mean_brown   = 0
    #self.mean_gray    = 0

    for x in 1..self.width
      for y in 1..self.height
        pixels = img.get_pixels(x-1,y-1,1,1)
        pix    = pixels[0]
        
        hsl_pix = pix.to_hsla
        hue     = hsl_pix[0]
        sat     = hsl_pix[1]/255
        light   = hsl_pix[2]/255
        
        if light <= 0.10
          self.mean_black += 1
        elsif light >= 0.95 and sat <=0.10
          self.mean_white += 1
        #elsif light >= 0.25 and light <= 0.75 and sat <=0.30
          #self.mean_gray += 1
        else
          
          case hue
          when 0..19
            self.mean_red     += 1
          when 20..40
            self.mean_orange  += 1
          when 41..85
            self.mean_yellow  += 1
          when 95..145
            self.mean_green   += 1
          when 155..205
            self.mean_cyan    += 1
          when 215..265
            self.mean_blue    += 1
          when 275..295
            self.mean_violet  += 1
          when 296..320
            self.mean_magenta += 1
          when 335..360
            self.mean_red     += 1
          end
          
        end

      end
    end

    amount_pixels = img.columns*img.rows

    self.mean_red     = (self.mean_red.to_f/amount_pixels).round(2)*100
    self.mean_yellow  = (self.mean_yellow.to_f/amount_pixels).round(2)*100
    self.mean_orange  = (self.mean_orange.to_f/amount_pixels).round(2)*100
    self.mean_green   = (self.mean_green.to_f/amount_pixels).round(2)*100
    self.mean_cyan    = (self.mean_cyan.to_f/amount_pixels).round(2)*100
    self.mean_blue    = (self.mean_blue.to_f/amount_pixels).round(2)*100
    self.mean_violet  = (self.mean_violet.to_f/amount_pixels).round(2)*100
    self.mean_magenta = (self.mean_magenta.to_f/amount_pixels).round(2)*100
    self.mean_black   = (self.mean_black.to_f/amount_pixels).round(2)*100
    self.mean_white   = (self.mean_white.to_f/amount_pixels).round(2)*100
    #self.mean_gray    = (self.mean_gray.to_f/amount_pixels).round(2)*100
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
