class CreatePersons < ActiveRecord::Migration
  def change
    create_table :persons do |t|
      t.string :name, :null => false

      t.timestamps
    end
  end
end
