# Different versions of a given Image (e.g., thumbnail, original, etc.)
class CreateImageVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :image_variants do |t|
      t.belongs_to :image, null: false
      t.integer :height
      t.integer :width
      t.string :format, limit: 31, null: false
      t.string :style, limit: 15, null: false
      t.text :url, null: false
      t.timestamps
    end
    add_index :image_variants, %i(image_id style height width)
  end
end
