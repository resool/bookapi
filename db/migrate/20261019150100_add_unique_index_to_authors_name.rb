class AddUniqueIndexToAuthorsName < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :authors, :name, unique: true, algorithm: :concurrently
  end
end
