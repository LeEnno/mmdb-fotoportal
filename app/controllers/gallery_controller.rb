class GalleryController < ApplicationController
  before_filter :redirect_if_not_authenticated

  PICTURES_PER_PAGE = 5

  def search
  end

  # show pictures of a folder (including upload field)
  def show_folder
    @folder = params[:folder_id].present? \
      ? Folder.find(params[:folder_id]) \
      : @user.root_folder
    @pictures = @folder.pictures.limit(PICTURES_PER_PAGE)
  end


  # show single picture page  
  def show_picture
    @picture = Picture.find(params[:picture_id])
    @user    = @picture.user
  end


  # load more pictures for infinite scroll
  def load_more_pictures
    page     = params[:page].to_i
    folder   = Folder.find(params[:folder_id].to_i)
    offset   = (page - 1) * PICTURES_PER_PAGE
    all_pics = folder.pictures

    @pictures = all_pics.offset(offset).limit(PICTURES_PER_PAGE)
    @has_more = all_pics.count > offset + PICTURES_PER_PAGE
  end


  # get faces for auto-completion
  def load_faces_and_keywords
    p = User.find(params[:user_id]).pictures
    render :json => {
      :faces    => p.joins(:persons).pluck('persons.name').uniq,
      :keywords => p.joins(:keywords).pluck('keywords.name').uniq
    }
  end


  # add new folder
  def add_folder
    @parent = Folder.find(params[:parent_id])
    f = Folder.new(:name => params[:name])
    f.parent = @parent # doesn't like to be mass-assigned =/
    f.user   = @user
    f.save
    @active_folder = Folder.find(params[:active_id])

    render :layout => false
  end


  # remove folder
  def remove_folder
    f = Folder.find(params[:folder_id])
    persons = []
    keywords = []

    f.picures.each do |p|
      p.keywords.each do |k|
        keywords << k if !k.in?(keywords)
      end
      p.persons.each do |ps|
        persons << ps if !ps.in?(persons)
      end

      p.delete_all
    end

    keywords.each do |k|
      k.delete if k.pictures.count < 1
    end

    persons.each do |ps|
      ps.delete if ps.pictures.count < 1
    end

    render :json => {
      :status => 'ok'
    }
  end
end
