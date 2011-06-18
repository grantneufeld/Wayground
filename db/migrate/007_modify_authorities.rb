# Change the :can_edit field to :can_update,
# and add the :can_approve field.
class ModifyAuthorities < ActiveRecord::Migration
  def self.up
    # The original migration was modified to have these fields,
    # so this will do nothing for new installations.
    # However, this migration will add them to existing installations.
    change_table :authorities do |t|
      t.rename :can_edit, :can_update unless t.column_exists?(:can_update, nil, {})
      t.boolean :can_approve unless t.column_exists?(:can_approve, nil, {})
    end
  end

  def self.down
  end
end
