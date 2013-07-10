class GalleryController < ApplicationController
  before_filter :redirect_if_not_authenticated

  PICTURES_PER_PAGE = 5

  # load pictures fr search/infinite scroll
  def search
    page     = params[:page].to_i
    offset   = (page - 1) * PICTURES_PER_PAGE

    search_results  = get_search_results
    @all_pics_count = search_results.count
    @has_more       = @all_pics_count > offset + PICTURES_PER_PAGE
    @pictures       = search_results.offset(offset).limit(PICTURES_PER_PAGE)
  end


  # show pictures of a folder (including upload field)
  def show_folder
    @folder = params[:folder_id].present? \
      ? Folder.find(params[:folder_id]) \
      : @user.root_folder
    
    all_pictures    = @folder.all_pictures
    @all_pics_count = all_pictures.count
    @pictures       = all_pictures.slice(0, PICTURES_PER_PAGE)
  end


  # show single picture page  
  def show_picture
    @picture = Picture.find(params[:picture_id])
    @user    = @picture.user
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


  # Remove folder.
  # 
  # For each children folder we collect keywords and persons, so we can check
  # afterwards if they have to be deleted completely because of no other
  # associated pictures. This keeps our database clean.
  # 
  # Afterwards we delete all children folder's pictures and the folders itself.
  # 
  def remove_folder
    f        = Folder.find(params[:folder_id])
    parent   = f.parent
    persons  = []
    keywords = []

    # iterate over children folder and store keywords * persons
    f.children.each do |child|
      child.pictures.each do |p|
        p.keywords.each { |k| keywords << k if !k.in?(keywords) }
        p.persons.each { |ps| persons << ps if !ps.in?(persons) }
        #p.delete
      end
      child.destroy
    end

    # delete folder and all orphaned keywords and persons
    f.destroy
    keywords.each { |k| k.delete if k.pictures.count < 1 }
    persons.each { |ps| ps.delete if ps.pictures.count < 1 }

    # give an arbitrary response
    render :json => {:parent_id => parent.id}
  end


  # PRIVATE METHODS
  # ------------------------------------------------------------------------------
  
  def get_search_results
    join_tables   = []
    where_fields  = []
    where_values  = {}
    operators     = params[:search_operators]

    params[:search_params].each do |key, val|
      
      # dates
      if key.in?('taken_at', 'created_at', 'updated_at')
        matches = val.match(/^(\d{2}.)(\d{2}.)?(\d{2,4})$/)
        val = Date.new(
          matches[-1].to_i,
          matches[-2].to_i,
          (matches.length - 1) > 2 ? matches[-3].to_i : 1
        )

        where_fields << "#{key} #{operators[key + '_operator']} :#{key}"
        where_values[key.to_sym] = val

      # numerics
      elsif key.in?('width', 'height', 'color_depth', 'filesize', 'height', 'focal_length', 'iso') || key =~ /^mean_/
        where_fields << "#{key} #{operators[key + '_operator']} :#{key}"
        where_values[key.to_sym] = val
      
      # specials
      # TODO fix color_space
      elsif key == 'color_space'
        where_fields << "#{key} = :#{key}"
        where_values[key.to_sym] = val
      
      elsif key == 'has_flash'
        val = val == 'an' ? 1 : 0
        where_fields << "#{key} = :#{key}"
        where_values[key.to_sym] = val
      
      # exact strings
      elsif key.in?('aperture', 'extension')
        where_fields << "#{key} = :#{key}"
        where_values[key.to_sym] = val

      # like strings
      elsif key.in?('title', 'location', 'camera')
        val = "%#{val}%"
        where_fields << "#{key} LIKE :#{key}"
        where_values[key.to_sym] = val

      # relations
      elsif key.in?('keywords', 'persons')
        join_tables << key.to_sym
        where_fields << "#{key}.name = :#{key}"
        where_values[key.to_sym] = val

      elsif key == 'folder_id'
        where_fields << "#{key} IN (:#{key})"
        where_values[key.to_sym] = Folder.find(val).children_ids
      end
    end

    # search results
    puts "huhu"
    puts join_tables
    puts where_fields.join(' AND ')
    puts where_values
    @user.pictures.joins(join_tables).where(where_fields.join(' AND '), where_values)
  end
end
