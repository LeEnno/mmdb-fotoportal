class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.timestamp :expires_at
      t.integer :user_id, :null => false

      t.timestamps
    end

    add_index :sessions, :user_id
  end
end
