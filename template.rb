# make sure the conan directory lives at ~/Rails/conan
# run: rails _3.1.0_ new app_name -m conan/template.rb -d mysql

require 'yaml'

route "root :to => 'home#index'"
add_source 'https://yoomee:wLjuGMTu30AvxVyIrq3datc73LVUkvo@gems.yoomee.com'

gem "rake", "0.8.7"
gem 'exception_notification'
gem 'country-select'
gem 'formtastic-bootstrap', :git => "git://github.com/cgunther/formtastic-bootstrap.git", :branch => "bootstrap-2"
gem 'whenever', :require => false
gem 'ym_core'
gem 'ym_cms'
gem 'ym_users'
gem 'ym_permalinks'

inside(".") do
  open("Gemfile", 'a') do |file|
    file << "\ngroup :development do\n"
    file << "  gem 'growl'\n"
    file << "  gem 'mailcatcher'\n"
    file << "  gem 'ruby-debug19'\n"
    file << "  gem 'ym_tools'\n"
    file << "  gem 'passenger'\n"
    file << "end\n"
    file << "group :development, :test do\n"
    file << "  gem 'rspec-rails'\n"
    file << "end\n"
    file << "group :test do\n"
    file << "  gem 'factory_girl_rails'\n"
    file << "  gem 'shoulda-matchers'\n"
    file << "  gem 'capybara'\n"
    file << "  gem 'guard-rspec'\n"
    file << "  gem 'sqlite3'\n"
    file << "end\n"
  end
end

# TODO: with rails 3.2 this will work instead of the above
# gem_group :development do
#  gem 'growl'
#  gem 'mailcatcher'
#  gem 'ruby-debug19'
#  gem 'ym_tools'
#  gem 'passenger'
# end
# gem_group :development, :test do
#   gem "rspec-rails"
# end
# gem_group :test do
#  gem "factory_girl_rails"
#  gem 'shoulda-matchers'
#  gem "capybara"
#  gem "guard-rspec"
#  gem "sqlite3"
# end

run("rm public/index.html")
run("rm app/assets/images/rails.png")
run("rm app/assets/javascripts/application.js")
run("rm app/views/layouts/application.html.erb")
run("cp ../conan/gitignore .gitignore")

Dir["../conan/*/"].each do |directory_path|
  directory = directory_path.split("/").last
  inside(directory) do
    Dir["../../conan/#{directory}/**/*.*"].each do |file_path|
      file_name = file_path.sub("../../conan/#{directory}/", '')
      if (file_directory = file_name.split("/").first(file_name.split("/").size-1).join("/")).present?
        run("mkdir -p #{file_directory}")
      end
      if file_name.match(/^assets/)
        run("cp #{file_path} #{file_name}")
      else
        file_text = File.read(file_path)
        open(file_name, "w") do |file|
          file << file_text.gsub(/\$AppName/, @app_name.camelize).gsub(/\$app_name/, @app_name.underscore).gsub(/\$APP_NAME/, @app_name.humanize.upcase).gsub(/\$App_name/, @app_name.humanize)
        end
      end
    end
  end
end

inside('config') do

  file_text = File.read('application.rb')
  open('application.rb', "w") do |file| 
    file << file_text.gsub(/whitelist_attributes = true/, 'whitelist_attributes = false')
  end
  
  file_text = File.read('environments/development.rb')
  open('environments/development.rb', 'w') do |file|
    file << file_text.gsub(/end$/, "  config.action_mailer.default_url_options = {:host => 'localhost:3000'}\n")
    # file << "\nconfig.action_mailer.default_url_options = {:host => 'localhost:3000'}\n"
    file << "  # Send email to mailcatcher\n"
    file << "  config.action_mailer.delivery_method = :smtp\n"
    file << "  config.action_mailer.smtp_settings = { :address => 'localhost', :port => 1025 }\n"
    file << "end"
  end

  file_text = File.read('environments/production.rb')
  open('environments/production.rb', 'w') do |file|
    file << file_text.gsub(/end$/, "  config.action_mailer.smtp_settings = {\n")    
    # file << "\nconfig.action_mailer.smtp_settings = {\n"
    file << "    :address        => 'mail.studentbabble.com',\n"
    file << "    :domain         => 'mail.studentbabble.com',\n"
    file << "    :authentication => :login,\n"
    file << "    :user_name      => 'info@studentbabble.com',\n"
    file << "    :password       => 'm:HE4,4JF2KL_{mG*;IG;(xGGjOA.;r',\n"
    file << "    :enable_starttls_auto => false\n"
    file << "  }\n"
    file << "end"
  end
  
  db_yaml = YAML.load_file('database.yml')
  %w{development test production}.each do |env|
    {'pool' => 5, 'timeout' => 5000}.each do |k, v|
      db_yaml[env][k] = v
    end
    unless env == 'development'
      %w{encoding reconnect username password socket}.each do |k|
        db_yaml[env].delete(k)
      end
      db_yaml[env]['adapter'] = 'sqlite3'
      db_yaml[env]['database'] = "db/#{env}.sqlite3"
    end
  end
  open('database.yml', 'w') do |file|
    file << YAML::dump(db_yaml)
  end
  
end

run('bundle')
run('bundle exec rake db:create')
run('bundle exec rails g ym_core:install')
run('bundle exec rails g ym_cms:install')
run('bundle exec rails g ym_users:install')
run('bundle exec rails g ym_permalinks:install')

if yes?("Run migrations?")
  run('bundle exec rake db:migrate')
  if yes?("Run seeds?")
    run('bundle exec rake db:seed')
  end
end