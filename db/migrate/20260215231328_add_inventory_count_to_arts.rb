class AddInventoryCountToArts < ActiveRecord::Migration[8.1]
  def change
    add_column :arts, :inventory_count, :integer, default: 0, null: false
  end
end
