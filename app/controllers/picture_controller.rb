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


  def edit
  end
end
