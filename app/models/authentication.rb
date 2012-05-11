# encoding: utf-8

# Authentications of Users from external services.
# Based on Oauth transactions with other websites (such as Twitter).
class Authentication < ActiveRecord::Base
  attr_accessor :new_user
  attr_accessible :provider, :uid, :name, :nickname, :email, :location, :image_url, :description, :url

  belongs_to :user

  def self.authenticate_callback!(auth, user = nil)
    authentication = self.find_by_provider_and_uid(auth["provider"], auth["uid"])
    if authentication.nil?
      authentication = create_with_auth!(auth, user)
    elsif user.present? && (user != authentication.user)
      raise Wayground::WrongUserForAuthentication
    end
    authentication
  end

  # Create a new Authentication, given an Oauth hash, for an optional user.
  def self.create_with_auth!(auth, user = nil)
    authentication = Authentication.new(user_attrs_from_auth(auth))
    if user.nil?
      user = User.create_from_authentication!(authentication)
      authentication.new_user = true
    else
      user.authentications << authentication
      user.save!
    end
    authentication
  end

  def self.user_attrs_from_auth(auth)
    user_info = auth['user_info'] || {}
    {
      :provider => auth['provider'], :uid => auth['uid'],
      :nickname => user_info['nickname'], :name => user_info['name'],
      :email => user_info['email'], :location => user_info['location'],
      :image_url => user_info['image'], :description => user_info['description'],
      :url => url_from_provider_auth(auth)
    }
  end

  # figure out the user’s url on the service, if available
  def self.url_from_provider_auth(auth)
    case auth['provider']
    when 'facebook'
      auth['urls']['Facebook'] if auth['urls'].present?
    when 'twitter'
      "https://twitter.com/#{auth['user_info']['nickname']}" if auth['user_info'].present?
    else
      nil
    end
  end

  def new_user?
    new_user
  end

  def label
    (provider == 'twitter' ? '@' : '') + (nickname || name || uid)
  end
end
