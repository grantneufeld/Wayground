require 'factory_girl'

FactoryGirl.define do
  # GLOBAL SEQUENCES
  # These are global sequences that can be used across factories to avoid name collisions.
  # For example, to get a unique email address in a given factory, call:
  #   email_attribute_name { generate(:email) }

  sequence :email do |n|
    "email#{n}-#{rand(100)}@factory.tld"
  end

  # FACTORIES

  factory :test_model do
    test_attribute 'value'
  end

  factory :authentication do
    user
    provider 'twitter'
    sequence(:uid) { |n| "#{format('%04d', n)}#{rand(9999)}" }
    sequence(:name) { |n| "Auth User#{n}" }
  end

  # note that this factory will require being called with a value for either :item or :area, or it will fail
  factory :authority do
    user
    factory :owner_authority do
      is_owner true
      can_create true
      can_view true
      can_update true
      can_delete true
      can_invite true
      can_permit true
      can_approve true
    end
  end

  factory :document do
    user
    sequence(:filename) { |n| "factory_document_#{n}.txt" }
    # size {4} # should be auto-set by Document model, based on self.data
    content_type 'text/plain'
    description  'This is a factory-generated Document.'
    data         'data'
  end

  factory :event do
    sequence(:start_at) { |n| n.days.from_now.to_datetime.to_s(:db) }
    sequence(:title)    { |n| "Factory Event #{n}" }
    editor
    is_approved true
    factory :event_future do
      # new events are in the future by default
    end
    factory :event_past do
      sequence(:start_at) { |n| n.days.ago.to_datetime.to_s(:db) }
    end
  end

  factory :external_link do
    sequence(:title) { |n| "Factory Link #{n}" }
    sequence(:url)   { |n| "http://link#{n}.factory/" }
    association :item, factory: :event
  end

  factory :image do
    title 'Factory Image'
    alt_text 'Factory alt text'
    description 'Factory generated Image.'
    attribution 'Factory Attribution'
    attribution_url 'http://attribution.tld/'
    license_url 'http://license.tld/'
  end

  factory :image_variant do
    image
    height '200'
    width '200'
    format 'png'
    style 'original'
    url 'http://test.tld/image.png'
  end

  factory :page do
    sequence(:filename) { |n| "factory_page_#{n}" }
    title       'Factory Page'
    description 'This is a factory-generated Page.'
    content     '<p>Generated by a Page factory.</p>'
    editor
  end

  # Requires being called with a value for either :item or :redirect
  factory :path do
    sequence(:sitepath) { |n| "/sitepath/factory_sitepath_#{n}" }
  end
  factory :item_path, parent: :path do
    item { create(:page, path: self) }
  end
  factory :redirect_path, parent: :path do
    redirect '/'
  end

  factory :project do
    creator
    owner
    is_visible true
    sequence(:filename)    { |n| "factory_project_#{n}" }
    sequence(:name)        { |n| "Factory Project #{n}" }
    sequence(:description) { |n| "Factory-generated project ##{n}." }
  end

  factory :setting do
    sequence(:key)   { |n| "factory_key_#{n}" }
    sequence(:value) { |n| "From factory (#{n})." }
  end

  factory :source do
    processor 'iCalendar'
    url       'test://factory.tld/factory.ics'
    # FIXME: change `Source#method` to `Source#http_method` to avoid method name collisions
    # method    'get'
    sequence(:title) { |n| "Factory Source #{n}" }
  end

  factory :sourced_item do
    source
    association :item, factory: :event
    last_sourced_at              { source.last_updated_at }
    sequence(:source_identifier) { |n| "#{n}@sourced_item.factory" }
  end

  factory :user, aliases: %i[creator editor owner] do
    email
    password              'password'
    password_confirmation 'password'
  end
  factory :email_confirmed_user, parent: :user do |_user|
    email_confirmed true
  end

  factory :user_token do
    user
    sequence(:token) { |n| "#{'x' * 63}#{n}" }
    sequence(:expires_at) { |n| n.days.from_now }
  end

  # item must be supplied
  factory :version do
    user
    edited_at { rand(100).hours.ago }
    title     'Factory Version'
    values    'abc' => 'def', 'ghi' => 'jkl'
  end

  # DEMOCRACY MODELS

  factory :ballot do
    election
    office { FactoryGirl.create(:office, level: election.level) }
    term_start_on { 30.days.from_now }
    term_end_on { 395.days.from_now }
    is_byelection false
    url 'http://ballot.url.tld/'
    description 'This is a Ballot.'
  end

  factory :candidate do
    ballot
    person
    #party
    #association :submitter, factory: :user
    sequence(:filename) { |n| "candidate#{n}" }
    sequence(:name) { |n| "Candidate #{n}" }
    is_rumoured false
    is_confirmed true
    is_incumbent false
    is_leader false
    is_acclaimed false
    is_elected false
    announced_on 1.month.ago
    quit_on nil
    vote_count 0
  end

  factory :contact do
    association :item, factory: :person
    sequence(:position) { |n| n }
    is_public true
    confirmed_at 1.day.ago
    expires_at 1.month.from_now
    sequence(:name) { |n| "Contact #{n}" }
    organization 'Organization'
    sequence(:email) { |n| "contact+#{n}@factory.tld" }
    twitter 'contacttwit'
    url 'http://factory.tld/contact'
    phone '000-000-0000'
    phone2 '123-456-7890 ext. 0'
    fax '098-765-4321'
    address1 'c/o Nobody'
    address2 '123 Main Street'
    city 'Townsville'
    province 'Alberta'
    country 'Canada'
    postal 'A1B 2C3'
  end

  factory :election do
    level
    sequence(:filename) { |n| "factory_election_#{n}" }
    sequence(:name) { |n| "Factory Election #{n}" }
    sequence(:end_on) { |n| n.months.from_now }
  end

  factory :level do
    sequence(:filename) { |n| "factory_level_#{n}_#{rand(1000)}" }
    sequence(:name) { |n| "Factory Level #{n}" }
  end

  factory :office do
    level
    sequence(:filename) { |n| "factory_office_#{n}" }
    sequence(:name) { |n| "Factory Office #{n}" }
    title 'Factory Officer'
  end

  factory :office_holder do
    office
    person
    start_on { (rand(10) + 1).years.ago }
  end

  factory :party do
    level
    sequence(:filename) { |n| "party#{n}" }
    sequence(:name) { |n| "Party #{n}" }
    sequence(:aliases) { |n| ["Party AKA #{n}", "#{n} Party"] }
    sequence(:abbrev) { |n| "PP#{n}" }
    is_registered true
    colour 'gray'
    url 'http://party.url.tld/'
    description 'This is a political Party.'
    established_on { (rand(10) + 1).years.ago }
    registered_on { established_on + 1.month }
  end

  factory :person do
    sequence(:filename) { |n| "person#{n}" }
    sequence(:fullname) { |n| "Person #{n}" }
    sequence(:aliases) { |n| ["Alias #{n}", "Nickname #{n}"] }
    bio 'Biography of a person.'
  end
end
