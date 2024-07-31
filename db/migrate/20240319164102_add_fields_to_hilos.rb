class AddFieldsToHilos < ActiveRecord::Migration[6.0]
  def change
    add_column :hilos, :type, :string
    add_column :hilos, :url, :string
    add_column :hilos, :dislikes, :integer, default: 0
  end
end
