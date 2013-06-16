class ChangePicturesKeywordsToKeywordsPictures < ActiveRecord::Migration
  def change
    rename_table :pictures_keywords, :keywords_pictures
  end
end
