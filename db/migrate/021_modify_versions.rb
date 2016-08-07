# Strip extraneous columns from Versions (relying on the hash field more instead)
class ModifyVersions < ActiveRecord::Migration
  def up
    remove_column :versions, :url if column_exists?(:versions, :url)
    remove_column :versions, :description if column_exists?(:versions, :description)
    remove_column :versions, :content if column_exists?(:versions, :content)
    remove_column :versions, :content_type if column_exists?(:versions, :content_type)
    remove_column :versions, :start_on if column_exists?(:versions, :start_on)
    remove_column :versions, :end_on if column_exists?(:versions, :end_on)
    add_column :versions, :values, :hstore
  end

  def down
    remove_column :versions, :values if column_exists?(:versions, :values)
    add_column :versions, :url, :text
    add_column :versions, :description, :text
    add_column :versions, :content, :text
    add_column :versions, :content_type, :string
    add_column :versions, :start_on, :date
    add_column :versions, :end_on, :date
  end
end
