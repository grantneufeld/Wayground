namespace :versions do
  desc 'Remove all Versions and create a single version record based on current state of applicable objects'
  task reset: :environment do
    Version.delete_all
    # reset the next versions.id
    ActiveRecord::Base.connection.execute("select setval('versions_id_seq', 1)")
    # all the new version records will have the first (presumably admin) user assigned as editor
    user = User.first
    Event.all.each do |event|
      event.editor = user
      event.edit_comment = 'versions reset'
      event.add_version
    end
    Page.all.each do |page|
      page.editor = user
      page.edit_comment = 'versions reset'
      page.add_version
    end
    # TODO: add any future versionable models here
  end
end
