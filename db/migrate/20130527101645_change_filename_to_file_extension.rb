class ChangeFilenameToFileExtension < ActiveRecord::Migration
  def change
    rename_column :pictures, :filename, :extension
  end
end
