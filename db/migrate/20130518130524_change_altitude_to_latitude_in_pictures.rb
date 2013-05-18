class ChangeAltitudeToLatitudeInPictures < ActiveRecord::Migration
  def change
    rename_column :pictures, :altitude, :latitude
  end
end
