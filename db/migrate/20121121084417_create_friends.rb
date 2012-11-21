class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.references :user
      t.integer :fbid
      t.string :name
      t.datetime :status_modified_date
      t.string :status

      t.timestamps
    end
  end
end
