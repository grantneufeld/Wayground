module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'
    when /^the sign up page$/
      '/signup'
    when /^the sign in page$/
      '/signin'
    when /^the sign out page$/
      '/signout'
    when /^the account page$/
      '/account'

    when /^the authorities index$/
      '/authorities'
    when /^an authority page$/
      /\/authorities\/[0-9]+/
    when /^the new authority page$/
      '/authorities/new'

    when /^the list of paths$/
      '/paths'
    when /^the (?:|custom )path form$/
      '/paths/new'
    when /^the edit form for custom path "([^\"]+)"$/
      path = Path.where(sitepath: $1).first
      edit_path_path(path)
    when /^"(\/.*)"$/
      $1

    when /^the documents index$/
      '/documents'

    when /^the upcoming events page$/
      '/events'
    when /^the event form$/
      '/events/new'
    when /^the page for the event "(.+)"$/
      event = Event.where(title: $1).first
      event_path(event)
    when /^the edit page for the event "(.+)"$/
      event = Event.where(title: $1).first
      edit_event_path(event)
    when /^the delete page for the event "(.+)"$/
      event = Event.where(title: $1).first
      delete_event_path(event)

    # the following are examples using path_to_pickle

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, :extra => $2                               #  or the forum's edit page

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.where(login: $1).first)

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
