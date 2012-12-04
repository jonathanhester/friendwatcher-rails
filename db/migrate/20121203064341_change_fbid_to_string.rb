class ChangeFbidToString < ActiveRecord::Migration
  def up
    change_column :friends, :fbid, :string
    change_column :users, :fbid, :string
  end

  def down
  end
end
