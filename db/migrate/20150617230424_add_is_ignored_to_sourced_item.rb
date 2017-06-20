# Allow SourcedItems to be remembered but ignored so they don’t get reprocessed.
class AddIsIgnoredToSourcedItem < ActiveRecord::Migration[5.1]
  def change
    add_column :sourced_items, :is_ignored, :boolean, default: false, null: false
    # allow item to be nil:
    change_column_null :sourced_items, :item_type, true
    change_column_null :sourced_items, :item_id, true
  end
end
