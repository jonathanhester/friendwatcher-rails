class AddIndexes < ActiveRecord::Migration
  def up
    add_index :friends, [:user_id, :fbid]
    add_index :users, :fbid
    add_index :devices, :user_id
    add_index :friend_events, :user_id
  end

  def down
  end
end
