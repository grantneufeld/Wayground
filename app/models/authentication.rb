require 'user'

# Authentications of Users from external services.
# Based on Oauth transactions with other websites (such as Twitter).
class Authentication < ApplicationRecord
  attr_accessor :new_user

  belongs_to :user

  def label
    (provider == 'twitter' ? '@' : '') + (nickname || name || uid)
  end
end
