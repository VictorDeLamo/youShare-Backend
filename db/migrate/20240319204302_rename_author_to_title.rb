class RenameAuthorToTitle < ActiveRecord::Migration[7.0]
  def change
    rename_column :hilos, :author, :title
  end
end
