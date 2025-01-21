class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :shop_id, null: false
      t.text :sentence, null: false

      t.timestamps
    end
  end
end
