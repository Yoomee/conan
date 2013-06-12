require 'yaml'

route "root :to => 'home#index'"
add_source 'https://yoomee:wLjuGMTu30AvxVyIrq3datc73LVUkvo@gems.yoomee.com'

gem 'exception_notification'
gem 'whenever', :require => false
gem 'ym_core', '~> 1.0.8'
gem 'ym_users', '~> 1.0.2'
gem 'ym_cms', '~> 1.0.0'

gem_group :development do
 gem 'growl'
 gem 'letter_opener'
 gem 'ruby-debug19'
 gem 'ym_tools'
 gem 'passenger'
end
gem_group :development, :test do
  gem "rspec-rails"
end
gem_group :test do
 gem "factory_girl_rails"
 gem 'shoulda-matchers'
 gem "capybara", "~> 1.1.4"
 gem "guard-rspec"
 gem "sqlite3"
end

run("rm public/index.html")
run("rm app/assets/images/rails.png")
run("rm app/assets/javascripts/application.js")
run("rm app/views/layouts/application.html.erb")
run("cp #{ENV['HOME']}/Rails/conan/gitignore .gitignore")
run("cp #{ENV['HOME']}/Rails/conan/ruby-version .ruby-version")

Dir["#{ENV['HOME']}/Rails/conan/*/"].each do |directory_path|
  directory = directory_path.split("/").last
  break if directory == 'ym_gem'
  inside(directory) do
    Dir["#{ENV['HOME']}/Rails/conan/#{directory}/**/*.*"].each do |file_path|
      file_name = file_path.sub("#{ENV['HOME']}/Rails/conan/#{directory}/", '')
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
    file << "  config.action_mailer.delivery_method = :letter_opener\n"
    file << "end"
  end

  file_text = File.read('environments/production.rb')
  open('environments/production.rb', 'w') do |file|
    file << file_text.gsub(/end$/, "  config.action_mailer.smtp_settings = {\n")
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
rake('db:create')
puts('Sleeping for 10 seconds for each gem....')
generate('ym_core:install')
sleep(10)
generate('ym_cms:install')
sleep(10)
generate('ym_users:install')
sleep(10)
generate('ym_permalinks:install')

if yes?("Run migrations?")
  rake('db:migrate')
  if yes?("Run seeds?")
    rake('db:seed')
  end
end