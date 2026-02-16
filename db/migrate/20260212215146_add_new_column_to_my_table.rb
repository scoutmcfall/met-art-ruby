class AddNewColumnToMyTable < ActiveRecord::Migration[8.1]
  def change
    add_column :Arts, :dimensions, :string
  end
end
