class CreateMetSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :met_subscriptions do |t|
      t.integer :met_object_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :met_subscriptions, [:user_id, :met_object_id], unique: true
    add_foreign_key :met_subscriptions, :users
  end
end
