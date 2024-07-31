class RenameTypeColumnInHilos < ActiveRecord::Migration[7.0]
  def change
    rename_column :hilos, :type, :hilo_type
  end
end
