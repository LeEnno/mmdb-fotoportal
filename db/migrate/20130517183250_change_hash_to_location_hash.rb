class ChangeHashToLocationHash < ActiveRecord::Migration
  def change
    rename_column :pictures, :hash, :path_hash
  end
end
