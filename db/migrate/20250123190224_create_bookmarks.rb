class CreateBookmarks < ActiveRecord::Migration[7.1]
  def change
    create_table :bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :shop_id, null: false

      t.timestamps
    end
    add_index :bookmarks, [:user_id, :shop_id], unique: true
  end
end
