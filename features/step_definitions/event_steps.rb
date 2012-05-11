# encoding: utf-8


# Populating the Events data

Given /^there are (\d+) upcoming events$/ do |count_str|
  count_total = count_str.to_i
  1..count_total.times do
    FactoryGirl.create(:event_future)
  end
end

Given /^there is an event(?:| on "([^\"]*)")(?:| titled) "([^\"]*)"(?:| with link "([^\"]*)")$/ do |datetime_str, title, url|
  if datetime_str.present?
    event = FactoryGirl.create(:event, :start_at => datetime_str, :title => title)
  else
    event = FactoryGirl.create(:event, :title => title)
  end
  if url.present?
    event.external_links.create!(:url => url)
  end
end

# Testing for event existence

Then /^I should see (\d+) events$/ do |count_str|
  count_expected = count_str.to_i
  # there should be count_expected elements on the page (probably divs) with the class "vevent"
  body.scan(/<[^>]+[ \t\r\n]class=\"vevent\"[^>]*>/).should have(count_expected).items
end

Then /^I should see the event "([^\"]*)"$/ do |title|
  # There should be an elment tagged with the class "summary" that contains the title
  body.should match(/class="([^\"]* )?summary( [^\"]*)?"[^>]*>[ \t\r\n]*#{title}[ \t\r\n]*</)
end

Then /^there should be an event "([^\"]*)"$/ do |title|
  Event.find_by_title(title).should be
end

Then /^there should not be an event "([^\"]*)"$/ do |title|
  Event.find_by_title(title).should be_nil
end


# Evaluating event details

Then /^I should see that the event starts on "([^\"]*)"$/ do |datetime_str|
  dt = DateTime.parse(datetime_str)
  body.should match(/[ \t\r\n]class="dtstart"[ \t\r\n]datetime="#{dt.to_s(:microformat)}">/)
end


# Testing ExternalLinks attached to Events

Then /^the event "([^\"]*)" should have the link "([^\"]*)"$/ do |title, url|
  Event.find_by_title(title).external_links.find_by_url(url).should be
end

Then /^the event "([^\"]*)" should not have any links$/ do |title|
  Event.find_by_title(title).external_links.count.should eq 0
end
