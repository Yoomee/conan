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

run "rm public/index.html "
run "rm app/assets/images/rails.png"
run "rm app/views/layouts/application.html.erb"

Dir["../conan/*/"].each do |directory_path|
  directory = directory_path.split("/").last
  inside(directory) do
    Dir["../../conan/#{directory}/**/*.*"].each do |file_path|
      file_name = file_path.sub("../conan/", '')
      run "mkdir -p #{file_name.split("/").first(file_name.split("/").size-1).join("/")}"
      file_text = File.read(file_path)
      open(file_name, "w") do |file|
        file << file_text.gsub(/\$AppName/, @app_name.camelize).gsub(/\$app_name/, @app_name.underscore).gsub(/\$APP_NAME/, @app_name.humanize.upcase).gsub(/\$App_name/, @app_name.humanize)
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
  
end