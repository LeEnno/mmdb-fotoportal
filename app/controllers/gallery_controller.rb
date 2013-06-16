class GalleryController < ApplicationController
  before_filter :redirect_if_not_authenticated

  def search
  end

  def show_folder
  end

  def show_picture
    @picture = Picture.find(params[:picture_id])
    @user    = @picture.user
  end
end
