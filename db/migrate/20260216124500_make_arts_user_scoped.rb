class MakeArtsUserScoped < ActiveRecord::Migration[8.1]
  def change
    # Add user reference to arts
    add_reference :arts, :user, foreign_key: true, index: true

    # Remove global unique index on met_object_id if it exists
    if index_exists?(:arts, :met_object_id, unique: true)
      remove_index :arts, column: :met_object_id
    end

    # Add uniqueness scoped to user
    add_index :arts, [:user_id, :met_object_id], unique: true
  end
end
