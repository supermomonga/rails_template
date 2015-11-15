require 'bundler'
Bundler.require

def choise(question, options)
  answers = options.keys
  idx = Ask.list question, options
  options.values[idx]
end

#===============================================================================
# Heroku
#===============================================================================

# heroku = Ask.confirm 'Is this the project for Heroku?'
heroku = false
if heroku
  gem_group :production do
    gem 'rails_12factor'
  end
end

#===============================================================================
# Twitter Bootstrap
#===============================================================================

use_bootstrap = Ask.confirm "Do you want to use Twitter Bootstrap3?"

# Bootswatch
if use_bootstrap
  gem 'bootstrap-sass', '~> 3.2.0.2'
  gem 'font-awesome-sass', '~> 4.2.0'
  use_bootswatch = Ask.confirm "Do you want to use Bootswatch theme?"
else
  use_bootswatch = false
end

# Bootswatch theme
if use_bootswatch
  gem 'rails-assets-bootswatch-scss', '~> 3.2.0.3'
  # https://github.com/log0ymxm/bootswatch-scss
  bootswatch_themes = %w(
    amelia cerulean cosmo custom cyborg darkly flatly global
    journal lumen paper readable sandstone simplex slate
    spacelab superhero united yeti)
  bootswatch_theme = Ask.list "What bootswatch theme do you want to use?", bootswatch_themes

  application <<-EOS
config.assets.precompile += %w` #{bootswatch_theme}.css #{bootswatch_theme}.js `
  EOS
end

#===============================================================================
# Production Database
#===============================================================================

production_database = choise("What database do you want to use?", {
                    'PostgreSQL' => 'pg',
                    'MySQL' => 'mysql2',
                    'MariaDB' => 'mysql2',
                    'SQLite3' => 'sqlite3'
                  })
gem_group :production do
  gem production_database
end

#===============================================================================
# Template Engine
#===============================================================================
template_engine = :slim
if template_engine == :slim
  gem 'slim-rails'
  application <<-EOS
config.generators do |g|
  g.template_engine :slim
end
  EOS
end



#===============================================================================
# Server
#===============================================================================
server = 'unicorn'
gem server

#===============================================================================
# User authentication
#===============================================================================
authentication = choise "Authentication", {
  "None" => nil,
  "Devise" => :devise,
  "OmniAuth" => :omniauth
}

if authentication
  gem authentication
end

if authentication == :omniauth
  # TODO: Community maintained provider gems
  # https://github.com/intridea/omniauth-github
  # https://github.com/arunagw/omniauth-twitter
  # https://github.com/Yesware/omniauth-google
  # https://github.com/zquestz/omniauth-google-oauth2
  # https://github.com/jamiew/omniauth-tumblr
  # https://github.com/datariot/omniauth-paypal
  # https://github.com/ropiku/omniauth-instagram
  # https://github.com/gumroad/omniauth-gumroad
end

#===============================================================================
# Admin panel
#===============================================================================

# https://github.com/yuroyoro/administa
# upmin
# rails-admin
if Ask.confirm "Admin panel?"
  gem 'activeadmin', github: 'gregbell/active_admin'
end

#===============================================================================
# Friendly ID
#===============================================================================
gem 'friendly_id', '~> 5.0.4'
# if Ask.confirm "Use friendly ID?"
# end

#===============================================================================
# Search
#===============================================================================
# gem 'ransack'
# gem 'squeel'

#===============================================================================
# Default Gems
#===============================================================================
gem 'foreman'
gem_group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'html2slim'
end
gem_group :production do
end
gem_group :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'factory_girl_rails'
end

#===============================================================================
# RSpec
#===============================================================================
application <<-EOS
config.generators do |g|
  g.test_framework :rspec
  g.view_specs false
end
EOS

#===============================================================================
# Factory Girl
#===============================================================================
application <<-EOS
config.generators do |g|
  g.fixture_replacement :factory_girl
end
EOS



#===============================================================================
# Bundle install
#===============================================================================
run 'bundle install'


#===============================================================================
# Generate and convert files
#===============================================================================

# Devise
#-------------------------------------------------------------------------------
case authentication
when :devise
  generate 'devise:views', '-f'
when :omniauth
  # TODO
end


# Convert all erb files into slim file
#-------------------------------------------------------------------------------
if template_engine == :slim
  inside 'app/views' do
    run <<-EOS
for x in app/views/**/*.erb
do
  erb2slim $x ${x%html.erb}slim && rm $x
done
    EOS
  end
end


# Bootstrap and bootswatch setting
#-------------------------------------------------------------------------------

## application.scss
if use_bootswatch
  generate 'bootswatch:install', bootswatch_theme, '-f'
  generate 'bootswatch:layout', bootswatch_theme, '-f'
# echo 'Rails.application.config.assets.precompile += %w( flatly.css )' >> config/initializers/assets.rb
# echo 'Rails.application.config.assets.precompile += %w( flatly.js )' >> config/initializers/assets.rb

## application.coffee

## layout file


# Devise setup
#-------------------------------------------------------------------------------
case authentication
when :devise
  run 'rails generate devise User'
  run 'rake db:migrate'
end

# ActiveAdmin setup
#-------------------------------------------------------------------------------


#
#-------------------------------------------------------------------------------

#===============================================================================
# Initialize git repository
#===============================================================================
git :init
git add: "."
git commit: "-a -m 'Initial commit'"



