class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :title, :null => false
      t.string :camera
      t.string :hash, :null => false
      t.integer :width, :null => false
      t.integer :height, :null => false
      t.integer :filesize, :null => false
      t.string :location
      t.float :longitude
      t.float :altitude
      t.integer :exposure_time
      t.integer :iso
      t.string :aperture
      t.integer :focal_length
      t.string :color_space
      t.integer :color_depth
      t.boolean :has_flash
      t.datetime :taken_at
      t.integer :mean_red
      t.integer :mean_green
      t.integer :mean_blue
      t.integer :mean_yellow
      t.integer :mean_orange
      t.integer :mean_violet
      t.integer :mean_magenta
      t.integer :mean_cyan
      t.integer :mean_brown
      t.integer :mean_white
      t.integer :mean_black
      t.integer :folder_id, :null => false

      t.timestamps
    end

    add_index :pictures, :folder_id
  end
end
