class CreateBoosts < ActiveRecord::Migration[7.0]
  def change
    create_table :boosts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hilo, null: false, foreign_key: true

      t.timestamps
    end
  end
end
