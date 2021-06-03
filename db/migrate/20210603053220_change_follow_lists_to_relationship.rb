class ChangeFollowListsToRelationship < ActiveRecord::Migration[5.2]
  def change
    rename_table :follow_lists, :relationships
  end
end
