class RemoveHiloTypeFromHilos < ActiveRecord::Migration[7.0]
  def change
    remove_column :hilos, :hilo_type, :string
  end
end
