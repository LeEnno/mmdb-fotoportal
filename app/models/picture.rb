class Picture < ActiveRecord::Base
  attr_accessible :aperture, :camera, :color_depth, :color_space, :exposure_time, :filename, :filesize, :focal_length, :folder, :has_flash, :height, :iso, :latitude, :location, :longitude, :mean_black, :mean_blue, :mean_cyan, :mean_green, :mean_magenta, :mean_orange, :mean_red, :mean_violet, :mean_white, :mean_yellow, :path_hash, :taken_at, :title, :width

  belongs_to :folder
  has_many :appearances, :dependent => :destroy
  has_many :persons, :through => :appearances

  has_many :keywords_pictures, :dependent => :destroy
  has_many :keywords, :through => :keywords_pictures
  
  has_and_belongs_to_many :keywords
  # should semantically be `belongs_to`, but `:through` wouldn't work
  has_one :user, :through => :folder

  after_initialize :_set_path_fields, :if => :new_record?
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
    
    # EXIF
    if format == 'JPEG'
      exif_data = EXIFR::JPEG.new(image_path)
      if exif_data.exif?
        self.camera        = exif_data.model              unless exif_data.model.nil?
        self.taken_at      = exif_data.date_time          unless exif_data.date_time.nil?
        self.exposure_time = exif_data.exposure_time.to_f unless exif_data.exposure_time.nil? # must be int
        self.aperture      = exif_data.f_number.to_s      unless exif_data.f_number.nil? # must be string

        self.latitude      = exif_data.gps.latitude       unless exif_data.gps.nil?
        self.longitude     = exif_data.gps.longitude      unless exif_data.gps.nil?
        self.location      = _fetch_location

        self.iso           = exif_data.iso_speed_ratings   if exif_data.respond_to?('iso_speed_ratings')
        self.color_space   = exif_data.color_space         if exif_data.respond_to?('color_space')
        self.focal_length  = exif_data.focal_length.to_f   if exif_data.respond_to?('focal_length')
        self.has_flash     = !!exif_data.flash             if exif_data.respond_to?('flash')
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
    self.updated_at == self.created_at && self.persons.count === 0
  end


  # walk through each pixel and save color means
  # 
  # We use the medium scale for better performance.
  # 
  def save_color_means
    require 'RMagick'
    img = Magick::Image::read(file_path('medium').to_s).first

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

    # walk through each pixel
    for x in 1..img.columns
      for y in 1..img.rows
        pixel   = img.get_pixels(x-1,y-1,1,1)[0]
        hsl_pix = pixel.to_hsla
        hue     = hsl_pix[0]
        sat     = hsl_pix[1]/255
        light   = hsl_pix[2]/255
        
        # black and white
        if light <= 0.10
          self.mean_black += 1
        elsif light >= 0.95 and sat <= 0.10
          self.mean_white += 1
        elsif sat >= 0.25
          
          # colors
          case hue
            when 0..19, 335..360
              self.mean_red     += 1
            when 20..40
              self.mean_orange  += 1
            when 41..85
              self.mean_yellow  += 1
            when 85..155
              self.mean_green   += 1
            when 155..205
              self.mean_cyan    += 1
            when 205..265
              self.mean_blue    += 1
            when 275..295
              self.mean_violet  += 1
            when 296..320
              self.mean_magenta += 1
          end # end case
        end # end if
      end # end for y
    end # end for x

    # make percentages
    amount_pixels     = img.columns * img.rows
    self.mean_red     = _as_percent(self.mean_red,     amount_pixels)
    self.mean_yellow  = _as_percent(self.mean_yellow,  amount_pixels)
    self.mean_orange  = _as_percent(self.mean_orange,  amount_pixels)
    self.mean_green   = _as_percent(self.mean_green,   amount_pixels)
    self.mean_cyan    = _as_percent(self.mean_cyan,    amount_pixels)
    self.mean_blue    = _as_percent(self.mean_blue,    amount_pixels)
    self.mean_violet  = _as_percent(self.mean_violet,  amount_pixels)
    self.mean_magenta = _as_percent(self.mean_magenta, amount_pixels)
    self.mean_black   = _as_percent(self.mean_black,   amount_pixels)
    self.mean_white   = _as_percent(self.mean_white,   amount_pixels)
    save
  end
  handle_asynchronously :save_color_means


  # PRIVATE METHODS
  # ----------------------------------------------------------------------------
  private

  def _set_path_fields
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


  def _as_percent(mean, amount_pixels)
    ((mean.to_f/amount_pixels).round(2) * 100).to_i
  end



  def _fetch_location
    if self.latitude.present? && self.longitude.present?
      require 'net/http'
      require 'json'
      
      url = "http://maps.googleapis.com/maps/api/geocode/json?latlng="+self.latitude.to_s+","+self.longitude.to_s+"&sensor=false&language=de"
      result = Net::HTTP.get(URI.parse(url))
      
      response = JSON.parse(result)
      results = response.fetch("results")
      
      locationString = "";
      tempAddress = "";
      for i in 1..results.size
        formatted_address = results.fetch(i-1).fetch("formatted_address")
        pos = formatted_address.index(',')
        if pos.nil?
          tempAddress = formatted_address;
        else
          tempAddress = formatted_address[0, pos];
        end # end if
        
        while tempAddress.include? " " do
          pos2 = tempAddress.index(' ')
          tempString = tempAddress[0, pos2]
          locationString = locationString + " " + tempString unless locationString.include? tempString
          tempAddress = tempAddress[pos2+1, tempAddress.size]
        end
        
        locationString = locationString + " " + tempAddress unless locationString.include? tempAddress        
      end # end for
      
      self.location = locationString
    end # end if
  end # end def


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
