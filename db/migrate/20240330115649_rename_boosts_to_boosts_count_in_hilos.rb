class RenameBoostsToBoostsCountInHilos < ActiveRecord::Migration[7.0]
  def change
    rename_column :hilos, :boosts, :boosts_count
  end
end
