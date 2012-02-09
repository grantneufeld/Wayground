# encoding: utf-8
require 'factory_girl'

# GLOBAL SEQUENCES
# These are global sequences that can be used across factories to avoid name collisions.
# For example, to get a unique email address in a given factory, call:
# 	f.email_attribute_name {Factory.next :email}

Factory.sequence :email do |n|
	"email#{n}@factory#{rand(100)}.tld"
end
Factory.sequence :filename do |n|
	"filename#{n}"
end
Factory.sequence :uid do |n|
	n
end

# FACTORIES

Factory.define :test_model do |f|
	f.test_attribute {'value'}
end

Factory.define :authentication do |f|
	f.user            { Factory(:user) }
	f.provider        {'twitter'}
	f.uid             { Factory.next :uid }
	f.sequence(:name) {|n| "Auth User#{n}"}
end

# note that this factory will require being called with a value for either :item or :area, or it will fail
Factory.define :authority do |f|
  f.user { Factory(:user) }
end
Factory.define :owner_authority, :parent => :authority do |f|
	f.is_owner { true }
	f.can_create { true }
	f.can_view { true }
	f.can_update { true }
	f.can_delete { true }
	f.can_invite { true }
	f.can_permit { true }
	f.can_approve { true }
end

Factory.define :document do |f|
  f.user { Factory(:user) }
  f.sequence(:filename) {|n| "factory_document_#{n}.txt"}
  #f.size {4} # should be auto-set by Document model, based on self.data
  f.content_type {'text/plain'}
  f.description {'This is a factory-generated Document.'}
  f.data {'data'}
end

Factory.define :event do |f|
  f.sequence(:start_at) {|n| n.days.from_now.to_datetime.to_s(:db)}
  f.sequence(:title) {|n| "Factory Event #{n}"}
end
Factory.define :event_future, :parent => :event do |f|
  # new events are in the future by default
end
Factory.define :event_past, :parent => :event do |f|
  f.sequence(:start_at) {|n| n.days.ago.to_datetime.to_s(:db)}
end

Factory.define :external_link do |f|
  f.sequence(:title) {|n| "Factory Link #{n}"}
  f.sequence(:url) {|n| "http://link#{n}.factory/"}
  f.item { Factory(:event) }
end

Factory.define :page do |f|
  f.sequence(:filename) {|n| "factory_page_#{n}"}
  f.title {'Factory Page'}
  f.description {'This is a factory-generated Page.'}
  f.content {'<p>Generated by a Page factory.</p>'}
  f.editor { Factory(:user) }
end

# Requires being called with a value for either :item or :redirect
Factory.define :path do |f|
  f.sequence(:sitepath) {|n| "/sitepath/factory_sitepath_#{n}"}
end
Factory.define :item_path, :parent => :path do |f|
  f.item { Factory(:page, :path => self)  }
end
Factory.define :redirect_path, :parent => :path do |f|
  f.redirect {'/'}
end

Factory.define :user do |user|
	user.email                 { Factory.next :email }
	user.password              { "password" }
	user.password_confirmation { "password" }
end
Factory.define :email_confirmed_user, :parent => :user do |user|
	user.email_confirmed { true }
end

# item must be supplied
Factory.define :version do |f|
  f.user { Factory(:user) }
  f.edited_at { (rand(100).hours.ago) }
  f.title { 'Factory Version' }
  f.content { '<p>Generated by a Version factory.</p>' }
  f.content_type { 'text/html' }
end
