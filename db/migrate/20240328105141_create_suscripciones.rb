class CreateSuscripciones < ActiveRecord::Migration[7.0]
  def change
    create_table :suscripciones do |t|
      t.references :user, null: false, foreign_key: true
      t.references :magazine, null: false, foreign_key: true

      t.timestamps
    end
  end
end
