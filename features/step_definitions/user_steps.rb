# many of these methods are derived from the ones that come from Clearance 


# General

Then /^(?:|I )should see error messages$/ do
	error_exp = '<div class="error_messages">'
	if response.respond_to? :should
		response.body.should match error_exp
	else
		assert_match error_exp, response.body
	end
end

# Database

Given /^no user exists with an email of "(.*)"$/ do |email|
	if response.respond_to? :should
		User.find_by_email(email).should be_nil
	else
		assert_nil User.find_by_email(email)
	end
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

# Session

Then /^(?:|I )should be signed in$/ do
	if response.respond_to? :should
		controller.signed_in?.should be_true
	else
		assert controller.signed_in?
	end
end

Then /^(?:|I )should be signed out$/ do
	if response.respond_to? :should
		controller.signed_in?.should be_false
	else
		assert ! controller.signed_in?
	end
end

When /^(?:|session is cleared|I quit the browser)$/ do
	request.reset_session
	controller.instance_variable_set(:@_current_user, nil)
end

#Given /^(?:|I )have signed in with "(.*)\/(.*)" with id ([0-9]+)$/ do |email, password, id|
#	Given %{I am signed up and confirmed as "#{email}/#{password}" with id #{id}}
#	And %{I sign in as "#{email}/#{password}"}
#end

Given /^(?:|I )have signed in with "(.*)\/(.*)"$/ do |email, password|
	Given %{I am signed up and confirmed as "#{email}/#{password}"}
	And %{I sign in as "#{email}/#{password}"}
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
	visit new_user_confirmation_path(:user_id => user,
	:token   => user.confirmation_token)
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

When /^(?:|I )sign in as "(.*)\/(.*)"$/ do |email, password|
	When %{I go to the sign in page}
	And %{I fill in "Email" with "#{email}"}
	And %{I fill in "Password" with "#{password}"}
	And %{I press "Sign In"}
end

When /^(?:|I )sign out$/ do
	visit '/session', :delete
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

When /^(?:|I )return next time$/ do
	When %{session is cleared}
	And %{I go to the homepage}
end
