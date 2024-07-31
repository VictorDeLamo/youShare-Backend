class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string
    add_column :users, :description, :text
    add_column :users, :cover, :string
    add_column :users, :avatar, :string
  end
end
