# A token for a user — for things like email confirmation.
class CreateUserTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :user_tokens do |t|
      t.belongs_to :user, null: false
      t.string :token, limit: 127, null: false
      t.datetime :expires_at
      t.datetime :last_used_at
      t.timestamps
    end
    add_index :user_tokens, :token
    add_index :user_tokens, :expires_at
    add_index :user_tokens, :last_used_at
  end
end
