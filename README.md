# Wayground

Web content framework.
http://wayground.ca/

A somewhat generic platform for handling web content management (CMS), contact relation management (CRM), democracy tools, calendaring, open data, content aggregation, etc.

Grant Neufeld
http://grantneufeld.ca/


## Installation

### Prerequisites

You must have ruby installed (at least version 1.9.3).

By default, we are using PostgreSQL as the database backend, so you will need an installation of that (although not necessarily on the same computer/server/host).

Depending on your ruby setup, you may need to prefix the `gem` calls that follow with `sudo`.

Make sure your ruby gem system is up to date:
 > gem update --system

Make sure you have Ruby on Rails installed:
 > gem install rails

You need a suitable web server installed (such as Apache, with the Passenger extension for ruby).

To install Passenger for running ruby websites with Apache:
 > gem install passenger

### Setup

Put the entire project directory where you want it on your web server’s file system.

Copy `config/database.default.yml` to `config/database.yml` and edit that file to use the appropriate configuration for your database. The default will use PostgreSQL. Using another database may require some changes to the migration files and may cause problems if the database doesn’t handle `array` or `hash` column types.

Copy `config/initializers/secret_token.rb.default` to `config/initializers/secret_token.rb`, then edit that file to use your own, made-up (random), secret key.

Copy `config/initializers/omniauth.rb.default` to `config/initializers/omniauth.rb`, then edit that file to use your own external service authentication codes.

From within the project directory, run the following command to ensure you have the required gems (and the required versions of those gems):
 > bundle

Run this command to setup the required data tables in your database:
 > bundle exec rake db:migrate RAILS_ENV#production

Set your web server’s configuration to point to the project directory (either for the server as a whole, or for the specific domain you want to be served). Restart your web server, if necessary, for it to start serving your new site.

Go to your new site and follow the “Sign Up” link to create your first user account on the site. The first user will automatically have admin privileges and can assign privileges to other users.

### Customizing

The overall look of the site is defined by the html template: `app/views/application.html.erb`

and by the stylesheets in: `app/assets/stylesheets/`

Be careful when editing `.erb` files that you don’t break the ruby code embedded in them. The ruby code in .erb files is wrapped in “<% … %>”.


## References

Portions of this code are taken from, or modified from, other open source projects:

* User access cucumber feature tests derived from Clearance http://github.com/thoughtbot/clearance
