class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :fbid
      t.string :token
      t.datetime :token_invalid_date
      t.boolean :token_invalid

      t.timestamps
    end
  end
end
