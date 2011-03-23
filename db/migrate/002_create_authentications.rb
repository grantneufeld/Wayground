class CreateAuthentications < ActiveRecord::Migration
	def self.up
		create_table :authentications do |t|
			t.belongs_to :user
			t.string :provider, :null => false
			t.string :uid, :null => false
			t.string :nickname
			t.string :name
			t.string :email
			t.string :location
			t.string :url
			t.string :image_url
			t.text :description
# user:belongs_to provider:string uid:string name:string nickname:string location:string url:string image_url:string
			t.timestamps
		end
		change_table :authentications do |t|
			t.index [:provider, :uid], :name=>'auth', :unique=>true
			t.index [:user_id, :provider], :name=>'user'
		end
	end

	def self.down
		drop_table :authentications
	end
end
