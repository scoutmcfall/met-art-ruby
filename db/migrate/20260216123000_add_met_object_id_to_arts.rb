class AddMetObjectIdToArts < ActiveRecord::Migration[8.1]
  def change
    add_column :arts, :met_object_id, :integer
    add_index :arts, :met_object_id, unique: true
  end
end
