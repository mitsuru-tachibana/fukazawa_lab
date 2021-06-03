class CreateFollowLists < ActiveRecord::Migration[5.2]
  def change
    create_table :follow_lists do |t|
      t.integer :follower_id
      t.integer :followed_id
      t.timestamps
    end

    add_index :follow_lists, :follower_id
    add_index :follow_lists, :followed_id
    add_index :follow_lists, [:follower_id, :followed_id], unique: true
  end
end
