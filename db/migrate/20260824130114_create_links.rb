class CreateLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :links do |t|
      t.string :short_code,   null: false, limit: 16
      t.text   :original_url, null: false
      t.timestamps
    end

    add_index :links, :short_code, unique: true
  end
end
