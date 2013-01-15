class AddIndexes < ActiveRecord::Migration
  def up
    add_index :friends, [:user_id, :fbid]
    add_index :users, :fbid
  end

  def down
  end
end
