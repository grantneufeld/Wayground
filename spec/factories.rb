require 'factory_girl'

# GLOBAL SEQUENCES
# These are global sequences that can be used across factories to avoid name collisions.
# For example, to get a unique email address in a given factory, call:
# 	f.email_attribute_name {Factory.next :email}

Factory.sequence :email do |n|
	"email#{n}@factory.tld"
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

Factory.define :user do |user|
	user.email                 { Factory.next :email }
	user.password              { "password" }
	user.password_confirmation { "password" }
end
Factory.define :email_confirmed_user, :parent => :user do |user|
	user.email_confirmed { true }
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
