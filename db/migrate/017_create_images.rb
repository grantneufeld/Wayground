# A graphic/visual image.
class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :title
      t.string :alt_text, limit: 127
      t.text :description
      t.string :attribution, limit: 127
      t.text :attribution_url
      t.text :license_url
      t.timestamps
    end
  end
end
