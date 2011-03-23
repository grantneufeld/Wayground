# encoding: utf-8

# Authentications of Users from external services.
# Based on Oauth transactions with other websites (such as Twitter).
class Authentication < ActiveRecord::Base
	belongs_to :user

	# Find an existing Authentication based on an incoming Oauth (‘auth’) hash.
	def self.authenticate(auth, user = nil)
		authentication = self.find_by_provider_and_uid(auth["provider"], auth["uid"])
		if authentication.nil?
			[nil,nil]
		else
			raise Wayground::WrongUserForAuthentication unless user.nil? || authentication.user == user
			[authentication, authentication.user]
		end
	end

	# Create a new Authentication, given an Oauth hash, for an optional user.
	def self.create_with_auth!(auth, user = nil)
		attrs = {:provider => auth['provider'], :uid => auth['uid'],
			:nickname => auth['user_info']['nickname'], :name => auth['user_info']['name'],
			:email => auth['user_info']['email'], :location => auth['user_info']['location'],
			:image_url => auth['user_info']['image'], :description => auth['user_info']['description']
		}
		# figure out the user’s url on the service
		case auth['provider']
		when 'facebook'
			attrs[:url] = auth['urls']['Facebook']
		when 'twitter'
			attrs[:url] = "http://twitter.com/#{attrs[:nickname]}"
		end
		authentication = Authentication.new(attrs)
		if user
			user.authentications << authentication
			user.save!
		else
			user = User.create_from_authentication!(authentication)
		end
		[authentication, user]
	end
end
