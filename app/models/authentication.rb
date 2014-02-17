require 'user'

# Authentications of Users from external services.
# Based on Oauth transactions with other websites (such as Twitter).
class Authentication < ActiveRecord::Base
  attr_accessor :new_user
  attr_accessible :provider, :uid, :name, :nickname, :email, :location, :image_url, :description, :url

  belongs_to :user

  def label
    (provider == 'twitter' ? '@' : '') + (nickname || name || uid)
  end
end
