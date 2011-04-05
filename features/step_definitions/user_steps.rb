# encoding: utf-8

# Some of these methods are derived from the ones that come from Clearance.


# UTILITY METHODS

def users_named(name_list, password = nil)
  names = name_list.split(/(?:, *|,? and )/)
  # get the users
  users = []
  names.each do |name|
    user_with_name = User.find_by_name(name)
    if user_with_name
      users << user_with_name
    else
      params = {:name => name}
      unless password.blank?
        params[:password] = password
        params[:password_confirmation] = password
      end
      users << Factory.create(:user, params)
    end
  end
  users
end


# Database

Given /^no user exists with an email of "(.*)"$/ do |email|
	if User.respond_to? :should
		User.find_by_email(email).should be_nil
	else
		assert_nil User.find_by_email(email)
	end
end


# Registration

Given /^there is (?:|already )a user "([^\"]*)"(?:| with password "([^\"]*)")$/ do |user_name, password|
  password = 'password' if password.blank?
  user = users_named(user_name, password)[0]
end

Given /^(?:|I )signed up with "(.*)\/(.*)"$/ do |email, password|
	user = User.find_by_email(email)
	unless user
		user = Factory :user,
		:email                 => email,
		:password              => password,
		:password_confirmation => password
	end
end

#Given /^(?:|I )am signed up and confirmed as "(.*)\/(.*)" with id ([0-9]+)$/ do |email, password, id|
#	user = User.find_by_email(email)
#	unless user
#		user = Factory :email_confirmed_user,
#		:id                    => id.to_i,
#		:email                 => email,
#		:password              => password,
#		:password_confirmation => password
#	end
#end

Given /^(?:|I )am signed up and confirmed as "(.*)\/(.*)"$/ do |email, password|
	user = User.find_by_email(email)
	unless user
		user = Factory :email_confirmed_user,
		:email                 => email,
		:password              => password,
		:password_confirmation => password
	end
end

When /^(?:|I )sign up as "([^\"]*)"(?:| with password "([^\"]*)")$/ do |user_name, password|
  password = 'password' if password.blank?
  visit '/signup'
  fill_in('email', :with => Factory.next(:email))
  fill_in('password', :with => password)
  fill_in('Confirm Password', :with => password) # password_confirmation
  fill_in('name', :with => user_name)
  click_button('Sign Up')
end


# Sign In

When /^I sign in as "([^\"]*)"(?:| with password "([^\"]*)")$/ do |user_name, password|
  password = 'password' if password.blank?
  user = users_named(user_name, password)[0]
  visit '/signin'
  fill_in('email', :with => user.email)
  fill_in('password', :with => password)
  click_button('Sign In')
end


# Sign Out

Given /^(?:|I )am not signed in$/ do
	# FIXME: catch exceptions if not currently logged in
	When "I sign out"
end
When /^(?:|I ) sign out$/ do
  visit '/signout'
	click_button 'Sign Out'
end


# OAuth

Given /^(?:|I )am pretending to access the external websites$/ do
	OmniAuth.config.test_mode = true
end
Given /^(?:|I )am actually using the external websites$/ do
	OmniAuth.config.test_mode = false
end

Given /^(?:|I )have my ([^ ]+) account(?:| @([^ ]+))$/ do |provider, uid|
	provider.downcase!
	uid ||= rand(255).to_s
	auth = {'uid' => uid}
	auth['user_info'] = {'nickname' => uid} if provider == 'twitter'
	OmniAuth.config.add_mock(provider.to_sym, auth)
end
When /^(?:|I )(?:|try to )sign in with my ([^ ]+) account(?:| @[^ ]+)(?:| again)$/ do |provider|
    When 'I go to the sign in page'
    When "I follow \"Sign in with #{provider.titleize}\""
end
When /^(?:|I )register my ([^ ]+) account(?:| @[^ ]+)(?:| again)$/ do |provider|
    When "I go to the account page"
    And "I follow \"Sign in with #{provider.titleize}\""
end
Given /^(?:|I )have previously signed in with my Twitter account(?:| @([^ ]+))$/ do |nick|
	nick_tag = nick.blank? ? '' : " @#{nick}"
	Given "I have my Twitter account#{nick_tag}"
	When "I sign in with my Twitter account#{nick_tag}"
	When "I sign out"
end
Then /^(?:|I )should be registered with my ([^ ]+) account(?:| @([^ ]+))$/ do |provider, nick|
	visit '/account'
	response_body.should match(/<a [^>]*href="[^"]+#{nick}"[^>]*>Your #{provider.titleize} account/)
end
Then /^(?:|I )should not be registered with my ([^ ]+) account(?:| @([^ ]+))$/ do |provider, nick|
	visit '/account'
	response_body.should_not match(/<a [^>]*href="[^"]+#{nick}"[^>]*>Your #{provider.titleize} account/)
end


# Session

Then /^(?:|I )should be signed in$/ do
	tag = /<[a-z]+ id="usermenu" class="signed-in">/
	if response_body.respond_to? :should
		response_body.should match(tag)
	else
		assert_match(tag, response_body)
	end
end

Then /^(?:|I )should be signed out$/ do
	tag = /<[a-z]+ id="usermenu" class="signed-out">/
	if response_body.respond_to? :should
		response_body.should match(tag)
	else
		assert_match(tag, response_body)
	end
end

#Given /^(?:|I )have signed in with "(.*)\/(.*)" with id ([0-9]+)$/ do |email, password, id|
#	Given %{I am signed up and confirmed as "#{email}/#{password}" with id #{id}}
#  And %{I sign in with #{email} and password "#{password}"}
#end

Given /^(?:|I )have signed in$/ do
  user = Factory(:user, :password => 'password')
  Given "I have signed in with my email #{user.email} and password \"password\""
end
Given /^(?:|I )have signed in with "(.*)\/(.*)"$/ do |email, password|
  Given "I have signed in with my email #{email} and password \"#{password}\""
end
Given /^(?:|I )have signed in with (?:|my )email [<"]?(.+@[^>\"]+)[>"]? and (?:|my )password "?([^\"]*)"?$/ do |email, password|
	Given %{I am signed up and confirmed as "#{email}/#{password}"}
  When %{I sign in with email #{email} and password "#{password}"}
end

When /^(?:|I )sign in with (?:|my )email [<"]?(.+@[^>\"]+)[>"]? and (?:|my )password "?([^\"]*)"?$/ do |email, password|
  visit '/signin'
  fill_in "Email", :with => email
  fill_in "Password", :with => password
  click_button "Sign In"
end


# Emails

Then /^a confirmation message should be sent to "(.*)"$/ do |email|
	user = User.find_by_email(email)
	sent = ActionMailer::Base.deliveries.first
	if response.respond_to? :should
		sent.to.should eq [user.email]
		sent.subject.should match /confirm/i
		user.confirmation_token.blank?.should be_false
		sent.body.should match /#{user.confirmation_token}/
	else
		assert_equal [user.email], sent.to
		assert_match /confirm/i, sent.subject
		assert !user.confirmation_token.blank?
		assert_match /#{user.confirmation_token}/, sent.body
	end
end

When /^(?:|I )follow the confirmation link sent to "(.*)"$/ do |email|
	user = User.find_by_email(email)
	visit "/account/confirm/#{user.confirmation_token}"
end

# FIXME: This is some ugly monkey-patching just to simulate a failure condition in the absence of proper stubbing support.
class User < ActiveRecord::Base
	@@test_fail_confirm_code = false
	def self.test_fail_confirm_code=(val)
		@@test_fail_confirm_code = val
	end
	alias :test_old_confirm_code! :confirm_code!
	def confirm_code!(in_code)
		if @@test_fail_confirm_code
			raise "failure"
		else
			test_old_confirm_code!(in_code)
		end
	end
end
When /^(?:|I )follow the confirmation link sent to "(.*)" with a failure$/ do |email|
	user = User.find_by_email(email)
	User.test_fail_confirm_code = true
	begin
		visit "/account/confirm/#{user.confirmation_token}"
	rescue Webrat::PageLoadError
		# a page load error is normal here, but we’ll need to manually follow the redirect
		visit response.location
	end
	User.test_fail_confirm_code = false
end

When /^(?:|I )try to confirm my email with "(.*)"$/ do |confirmation_code|
	visit "/account/confirm/#{confirmation_code}"
end

Then /^a password reset message should be sent to "(.*)"$/ do |email|
	user = User.find_by_email(email)
	sent = ActionMailer::Base.deliveries.first
	if response.respond_to? :should
		sent.to.should eq [user.email]
		sent.subject.should match /password/i
		user.confirmation_token.blank?.should be_false
		sent.body.should match /#{user.confirmation_token}/
	else
		assert_equal [user.email], sent.to
		assert_match /password/i, sent.subject
		assert !user.confirmation_token.blank?
		assert_match /#{user.confirmation_token}/, sent.body
	end
end

When /^(?:|I )follow the password reset link sent to "(.*)"$/ do |email|
	user = User.find_by_email(email)
	visit edit_user_password_path(:user_id => user,
	:token   => user.confirmation_token)
end

#When /^(?:|I )try to change the password of "(.*)" without token$/ do |email|
#	user = User.find_by_email(email)
#	visit edit_user_password_path(:user_id => user)
#end
#
#Then /^(?:|I )should be forbidden$/ do
#	assert_response :forbidden
#end

# Actions

When /^(?:|I )sign out$/ do
  visit signout_path, :delete
end

When /^(?:|I )request password reset link to be sent to "(.*)"$/ do |email|
	When %{I go to the password reset request page}
	And %{I fill in "Email address" with "#{email}"}
	And %{I press "Reset password"}
end

When /^(?:|I )update my password with "(.*)\/(.*)"$/ do |password, confirmation|
	And %{I fill in "Choose password" with "#{password}"}
	And %{I fill in "Confirm password" with "#{confirmation}"}
	And %{I press "Save this password"}
end

When /^(?:|I )quit the browser$/ do
	# FIXME: this code from clearance gem doesn’t work anymore. need a way to “quit the browser” in cucumber step
	#request.reset_session
	#controller.instance_variable_set(:@_current_user, nil)
end

When /^(?:|I )return next time$/ do
	When %{I quit the browser}
	And %{I go to the homepage}
end
