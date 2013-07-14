class PictureController < ApplicationController

  # SAVE UPLOADED IMAGE
  # ----------------------------------------------------------------------------
  # 
  def upload
    file_contents = params[:file]
    @picture      = Picture.new(:title => file_contents.original_filename)
    
    # wb = write binary, to avoid encoding conversion errors
    # see http://stackoverflow.com/questions/10177674/how-do-i-embed-an-uploaded-binary-files-ascii-8bit-in-an-xml-utf-8#answer-11683990
    File.open(@picture.file_path('original'), 'wb') do |file|
      file.write(file_contents.read)
      @picture.extract_metadata
      @picture.folder = Folder.find(params[:folder][:id])
      @picture.save
    end

    render :json => {:permalink => picture_url(:picture_id => @picture.id)}
  end


  # EDIT PERSONS, KEYWORDS, TITLE AND FOLDERS VIA AJAX
  # ----------------------------------------------------------------------------
  # 
  # params[:picture][:person] is array
  # params[:picture][:persons] is string with comma-separated values
  # 
  def edit
    @picture = Picture.find(params[:picture][:id])
    
    # collect person names
    p_names = params[:picture][:person] || []
    p_names = p_names + params[:picture][:persons].split(',') if params[:picture][:persons].present?

    # find or create person and add it to our picture
    p_names.map!{ |p_name| p_name.strip }.each do |p_name|
      next if p_name.empty?
      p = Person.find_or_create_by_name(p_name)
      @picture.persons << p if !@picture.persons.pluck(:name).include?(p_name)
    end

    # delete persons that have been removed from input field
    @picture.persons = @picture.persons.reject do |p|
      if p.name.in?(p_names)
        false
      else
        # not only delete from join-table but also from persons-table itself if
        # it doesn't belong to any other pictures
        p.delete if p.pictures.count == 1
        true
      end
    end


    # find or create keyword and add it to our picture
    k_names = []
    k_names = k_names + params[:picture][:keywords].split(',') if params[:picture][:keywords].present?
    k_names.map!{ |k_name| k_name.strip }.each do |k_name|
      next if k_name.empty?
      k = Keyword.find_or_create_by_name(k_name)
      @picture.keywords << k if !@picture.keywords.pluck(:name).include?(k_name)
    end

    # delete persons that have been removed from input field
    @picture.keywords = @picture.keywords.reject do |k|
      if k.name.in?(k_names)
        false
      else
        # not only delete from join-table but also from keywords-table itself if
        # it doesn't belong to any other pictures
        k.delete if k.pictures.count == 1
        true
      end
    end


    # save folder and changes
    @picture.title      = params[:picture][:title] if params[:picture][:title].present?
    @picture.folder     = Folder.find(params[:picture][:folder])
    @picture.updated_at = Time.now
    @picture.save

    # return faces as printable string
    # 
    # We only return the faces, because the keywords are a single input and the
    # value is likely to remain the same as at the time of submitting the form.
    # Same applies to the folder.
    # 
    render :json => {
      :persons => @picture.persons_as_string
    }
  end

end
