
def choise(question, options)
  question_text = "%s\n%s" % [
    question,
    options.with_index(1).map {|(k, v), i|
      "  #{i}. #{k}"
    }.join("\n")
  ]
  ans = options.keys[ask(question_text).to_i - 1]
  if ans
    puts "You choose `#{ans}`"
    options[ans]
  else
    puts "Sorry, try again."
    choise(question, options)
  end
end

return unless yes? 'Use basic template?'

heroku = yes? 'Is this the project for Heroku?'
bootswatch = yes? 'Are you want to use bootswatch?'


database = choise("What database do you want to use?", [
                    'PostgreSQL' => 'pg',
                    'MySQL' => 'mysql2',
                    'MariaDB' => 'mariadb',
                    'SQLite3' => 'sqlite3'
                  ])

database = ask_database
while()


# Gems {{{
gem 'slim-rails'
gem 'unicorn'
gem 'devise'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'bootstrap-sass', '~> 3.2.0.2'
gem 'rails-assets-bootswatch-scss', '~> 3.2.0.3' if bootswatch
gem 'font-awesome-sass', '~> 4.2.0'
gem 'friendly_id', '~> 5.0.4'
gem 'ransack'
gem 'squeel'
gem_group :development do
  gem 'sqlite3'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'html2slim'
end
gem_group :production do
  gem 'pg'
  gem 'rails_12factor' if heroku
end
gem_group :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'factory_girl_rails'
end
# }}}


application <<-EOS
config.generators do |g|
  g.template_engine :slim
  g.test_framework :rspec
  g.fixture_replacement :factory_girl
  g.view_specs false
end
EOS

# application <<-EOS
# config.generators do |g|
#   g.template_engine :slim
#   g.test_framework :rspec
#   g.fixture_replacement :factory_girl
#   g.view_specs false
# end
# EOS

run 'bundle install'

# Bootswatch
if bootswatch
  bootswatch_theme = :flatly
  application <<-EOS
config.assets.precompile += %w` #{bootswatch_theme}.css #{bootswatch_theme}.js `
  EOS
end






# Devise
generate 'devise:views', '-f'



## Convert all erb files into slim file
inside 'app/views' do
  run 'for x in app/views/**/*.erb; do erb2slim $x ${x%html.erb}slim && rm $x; done'
end

run 'bundle install'

git :init
git add: "."
git commit: "-a -m 'Initial commit'"



