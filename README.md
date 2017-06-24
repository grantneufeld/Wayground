# Wayground

Web content framework.
http://wayground.ca/

Twitter: @[wayground](https://twitter.com/wayground)

A somewhat generic platform for handling web content management (CMS),
contact relation management (CRM), democracy tools, calendaring, open data,
content aggregation, etc.

Project lead: [Grant Neufeld](http://grantneufeld.ca/)


## Installation

### Prerequisites

You must have [ruby](https://www.ruby-lang.org/) installed (at least version 2.4).
You may want to use something like [RVM](https://rvm.io/) to manage installation of ruby.

By default, we are using [PostgreSQL](http://www.postgresql.org/) as the database backend,
so you will need an installation of that (although not necessarily on the same computer/server/host).
Version 9.3 or later recommended.

These commands should be issued from the project directory (e.g., `~/projects/wayground`).
Depending on your ruby setup, you may need to prefix the `gem` calls that follow with `sudo`.

Make sure your [ruby gem](http://rubygems.org/) system is up to date:

    gem update --system

Make sure you have [Bundler](http://bundler.io/) for installing gems:

    gem install bundler

For deployment, you either need a hosted service that can support Ruby on Rails and your database,
or you need a suitable web server installed
(such as [Apache](https://httpd.apache.org/), with the
[Passenger](https://www.phusionpassenger.com/) extension for ruby).

For non-production installations (e.g., for developers),
please also refer to the developer documentation: `doc/Developers/Setup.md`.

### Setup

Put the entire project directory where you want it on your web server’s file system.

Copy `config/database.default.yml` to `config/database.yml` and edit that file
to use the appropriate configuration for your database.
The default will use PostgreSQL.
Using another database may require some changes to the migration files
and may cause problems if the database doesn’t handle `array` or `hash` column types.

Copy `config/initializers/secret_token.rb.default` to `config/initializers/secret_token.rb`,
then edit that file to use your own, made-up (random), secret key.

Copy `config/initializers/omniauth.rb.default` to `config/initializers/omniauth.rb`,
then edit that file to use your own external service authentication codes.

From within the project directory, run the following command to ensure you have the required gems
(and the required versions of those gems):

    bundle

Run this command to setup the required data tables in your database:

    bundle exec rails db:migrate RAILS_ENV#production

On production servers, run this command to precompile the assets
(javascripts, stylesheets,…):

    bundle exec rails assets:precompile

Set your web server’s configuration to point to the project directory
(either for the server as a whole, or for the specific domain you want to be served).
Restart your web server, if necessary, for it to start serving your new site.

Go to your new site and follow the “Sign Up” link to create your first user account on the site.
The first user will automatically have admin privileges and can assign privileges to other users.

### Customizing

The overall look of the site is defined by the html template: `app/views/application.html.erb`

and by the stylesheets in: `app/assets/stylesheets/`

Be careful when editing `.erb` files that you don’t break the ruby code embedded in them.
The ruby code in .erb files is wrapped in “<% … %>”.


## Third Party Content

### Code

Portions of this code are taken from, or modified from, other open source projects:

* User access cucumber feature tests derived from [Clearance](http://github.com/thoughtbot/clearance)

### Fonts

* [Font Awesome](http://fontawesome.io/) by Dave Gandy.
License: [SIL OFL 1.1](http://scripts.sil.org/OFL)
* [Ubuntu Font Family](http://font.ubuntu.com/).
License: [Ubuntu Font Licence: Version 1.0](http://font.ubuntu.com/licence/)
