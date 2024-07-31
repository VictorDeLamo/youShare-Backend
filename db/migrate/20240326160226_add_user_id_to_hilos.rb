class AddUserIdToHilos < ActiveRecord::Migration[7.0]
  def change
    add_column :hilos, :user_id, :integer
  end
end
