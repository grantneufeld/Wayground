# Associate an Image with events.
class AddImageToEvents < ActiveRecord::Migration[5.1]
  def change
    change_table :events do |t|
      t.belongs_to :image
    end
  end
end
