# encoding: utf-8

# Some of these methods are derived from the ones that come from Clearance.


# UTILITY METHODS

# Find the named users, creating any users not found.
# @param [String] name_list List of user names (separated by commas or ‘ and ’)
# @param [String] password
# @return [Array<User>] The users
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
#  user = User.find_by_email(email)
#  unless user
#    user = Factory :email_confirmed_user,
#    :id                    => id.to_i,
#    :email                 => email,
#    :password              => password,
#    :password_confirmation => password
#  end
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
  fill_in('user_email', :with => Factory.next(:email))
  fill_in('user_password', :with => password)
  fill_in('user_password_confirmation', :with => password)
  fill_in('user_name', :with => user_name)
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
  step "I sign out"
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
  step 'I go to the sign in page'
  step "I follow \"Sign in with #{provider.titleize}\""
end
When /^(?:|I )(?:|try to )register my ([^ ]+) account(?:| @[^ ]+)(?:| again)$/ do |provider|
  be_on_account_page
  click_link "Sign in with #{provider.titleize}"
end
Given /^(?:|I )have previously signed in with my Twitter account(?:| @([^ ]+))$/ do |nick|
  nick_tag = nick.blank? ? '' : " @#{nick}"
  step "I have my Twitter account#{nick_tag}"
  step "I sign in with my Twitter account#{nick_tag}"
  step "I sign out"
end
Then /^(?:|I )should be registered with my ([^ ]+) account(?:| @([^ ]+))$/ do |provider, nick|
  be_on_account_page
  body.should match(/<a [^>]*href="[^"]+#{nick}"[^>]*>Your #{provider.titleize} account/)
end
Then /^(?:|I )should not be registered with my ([^ ]+) account(?:| @([^ ]+))$/ do |provider, nick|
  be_on_account_page
  if @noted_user.present?
    if body.match(/<h1>User: #{@noted_user}<\/h1>/)
      # we’re on the account page of the user being checked
      body.should_not match(/<a [^>]*href="[^"]+#{nick}"[^>]*>Your #{provider.titleize} account/)
    else
      body.should match(/<a [^>]*href="[^"]+#{nick}"[^>]*>Your #{provider.titleize} account/)
    end
  else
    body.should_not match(/<a [^>]*href="[^"]+#{nick}"[^>]*>Your #{provider.titleize} account/)
  end
end

When /^(?:|I )note which user I am$/ do
  be_on_account_page
  @noted_user = body.match(/<h1>User: (.+)<\/h1>/)[1]
end

def be_on_account_page
  # some ugliness here because going through a remote host for OAuth messes up Capybara’s session tracking
  unless current_path == '/account'
    signin_link = find_link('My Account') rescue nil
    if signin_link
      click_link 'My Account'
    else
      visit '/account'
    end
  end
end

# Session

Then /^(?:|I )should be signed in$/ do
  tag = /<[a-z]+ id="usermenu" class="signed-in">/
  if body.respond_to? :should
    body.should match(tag)
  else
    assert_match(tag, body)
  end
end

Then /^(?:|I )should be signed out$/ do
  tag = /<[a-z]+ id="usermenu" class="signed-out">/
  if body.respond_to? :should
    body.should match(tag)
  else
    assert_match(tag, body)
  end
end

#Given /^(?:|I )have signed in with "(.*)\/(.*)" with id ([0-9]+)$/ do |email, password, id|
#  step %{I am signed up and confirmed as "#{email}/#{password}" with id #{id}}
#  step %{I sign in with #{email} and password "#{password}"}
#end

Given /^(?:|I )have signed in$/ do
  user = Factory(:user, :password => 'password')
  step "I have signed in with my email #{user.email} and password \"password\""
end
Given /^(?:|I )have signed in with "(.*)\/(.*)"$/ do |email, password|
  step "I have signed in with my email #{email} and password \"#{password}\""
end
Given /^(?:|I )have signed in with (?:|my )email [<"]?(.+@[^>\"]+)[>"]? and (?:|my )password "?([^\"]*)"?$/ do |email, password|
  step %{I am signed up and confirmed as "#{email}/#{password}"}
  step %{I sign in with email #{email} and password "#{password}"}
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
  # a class variable to track whether we want confirm_code! to fail or not
  @@test_fail_confirm_code = false
  def self.test_fail_confirm_code=(val)
    @@test_fail_confirm_code = val
  end
  # keep a reference to the original confirm_code! method
  alias :test_old_confirm_code! :confirm_code!
  # override the confirm_code! method with our testing version
  def confirm_code!(in_code)
    # check if we want to force failure
    if @@test_fail_confirm_code
      raise "failure"
    else
      # if not forcing failure, just pass the call to the normal confirm_code! method
      test_old_confirm_code!(in_code)
    end
  end
end
When /^(?:|I )follow the confirmation link sent to "(.*)" with a failure$/ do |email|
  user = User.find_by_email(email)
  User.test_fail_confirm_code = true
  visit "/account/confirm/#{user.confirmation_token}"
  # Because of the ugliness between rack test and capybara’s default domains (example.org vs. example.com),
  # it’s not visiting the redirect location and instead returning a weird redirect warning page.
  click_link('redirected')
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
#  user = User.find_by_email(email)
#  visit edit_user_password_path(:user_id => user)
#end
#
#Then /^(?:|I )should be forbidden$/ do
#  assert_response :forbidden
#end

# Actions

When /^(?:|I )sign out$/ do
  begin
    click_link 'Sign Out' unless current_path == '/signout'
    click_button('Sign Out')
  rescue Capybara::ElementNotFound
  end
end

When /^(?:|I )request password reset link to be sent to "(.*)"$/ do |email|
  step %{I go to the password reset request page}
  step %{I fill in "Email address" with "#{email}"}
  step %{I press "Reset password"}
end

When /^(?:|I )update my password with "(.*)\/(.*)"$/ do |password, confirmation|
  step %{I fill in "Choose password" with "#{password}"}
  step %{I fill in "Confirm password" with "#{confirmation}"}
  step %{I press "Save this password"}
end

When /^(?:|I )quit the browser$/ do
  # FIXME: this code from clearance gem doesn’t work anymore. need a way to “quit the browser” in cucumber step
  #request.reset_session
  #controller.instance_variable_set(:@_current_user, nil)
end

When /^(?:|I )return next time$/ do
  step %{I quit the browser}
  step %{I go to the homepage}
end

Then /^(?:|I )should see my account details$/ do
  current_path.should match(path_to('the account page'))
  page.should have_selector('h1', :text => 'User: ')
end