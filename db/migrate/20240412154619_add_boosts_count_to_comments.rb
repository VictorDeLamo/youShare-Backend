class AddBoostsCountToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :boosts_count, :integer, default: 0
  end
end
