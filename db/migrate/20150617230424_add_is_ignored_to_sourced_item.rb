class AddIsIgnoredToSourcedItem < ActiveRecord::Migration
  def change
    add_column :sourced_items, :is_ignored, :boolean, default: false, null: false
    # allow item to be nil:
    change_column_null :sourced_items, :item_type, true
    change_column_null :sourced_items, :item_id, true
  end
end
