require 'factory_girl'

# GLOBAL SEQUENCES
# These are global sequences that can be used across factories to avoid name collisions.
# For example, to get a unique email address in a given factory, call:
# 	f.email_attribute_name {Factory.next :email}

Factory.sequence :email do |n|
	"user#{n}@test.tld"
end

Factory.sequence :filename do |n|
	"filename#{n}"
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
