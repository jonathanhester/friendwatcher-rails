class AddFriendEvent < ActiveRecord::Migration
  def change
    create_table :friend_events do |t|
      t.references :user
      t.string :fbid
      t.string :name
      t.string :event

      t.timestamps
    end

  end


end
