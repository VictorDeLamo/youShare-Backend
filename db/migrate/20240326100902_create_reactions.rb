class CreateReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hilo, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
    # Aquí se añade un índice para asegurar la unicidad del par user_id y hilo_id
    add_index :reactions, [:user_id, :hilo_id], unique: true
  end
end
