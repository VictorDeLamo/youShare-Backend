class AddLikesToHilos < ActiveRecord::Migration[7.0]
  def change
    add_column :hilos, :likes, :integer, default:0
  end
end
