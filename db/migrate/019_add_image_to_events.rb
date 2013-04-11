class AddImageToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.belongs_to :image
    end
  end
end
