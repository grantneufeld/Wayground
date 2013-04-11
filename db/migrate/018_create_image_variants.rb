class CreateImageVariants < ActiveRecord::Migration
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
    add_index :image_variants, [:image_id, :style, :height, :width]
  end
end
