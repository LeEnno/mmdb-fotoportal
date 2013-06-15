class PictureController < ApplicationController

  def upload
    file_contents = params[:file]
    @picture      = Picture.new(:title => file_contents.original_filename)
    
    # wb = write binary, to avoid encoding conversion errors
    # see http://stackoverflow.com/questions/10177674/how-do-i-embed-an-uploaded-binary-files-ascii-8bit-in-an-xml-utf-8#answer-11683990
    File.open(@picture.file_path('original'), 'wb') do |file|
      file.write(file_contents.read)
      @picture.extract_metadata
      @picture.folder = @user.root_folder
      @picture.save
    end

    render :json => {:permalink => picture_url(:picture_id => @picture.id)}
  end


  # Edit persons, folders and keywords via AJAX
  # 
  # params[:picture][:person] is array
  # params[:picture][:persons] is string with comma-separated values
  # 
  def edit
    @picture = Picture.find(params[:picture][:id])
    
    # collect person names
    p_names = params[:picture][:person] || []
    p_names = p_names + params[:picture][:persons].split(',') if params[:picture][:persons].present?

    # find or create person and add it to out picture
    p_names.map!{ |p_name| p_name.strip }.each do |p_name|
      p = Person.find_or_create_by_name(p_name)
      @picture.persons << p if !@picture.persons.pluck(:name).include?(p_name)
    end

    # delete persons that have been removed from input field
    @picture.persons = @picture.persons.reject do |p|
      if p.name.in?(p_names)
        false
      else
        p.delete # not only delete from join-table but also from persons-table itself
        true
      end
    end

    # save changes
    @picture.updated_at = Time.now
    @picture.save

    render :json => {
      :persons => @picture.persons_as_string
    }
  end
end
