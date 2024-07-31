class AddMagazineRefToHilos < ActiveRecord::Migration[7.0]
  def change
    add_reference :hilos, :magazine, null: false, foreign_key: true
  end
end
