class CreateCommentBoosts < ActiveRecord::Migration[7.0]
  def change
    create_table :comment_boosts do |t|
      t.references :comment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
