# make sure the conan directory lives at ~/Rails/conan
# cd ~/Rails/Gems
# run: rails _3.1.0_ plugin new gem_name --full -m ~/Rails/conan/ym_gem/template.rb

add_source 'https://yoomee:wLjuGMTu30AvxVyIrq3datc73LVUkvo@gems.yoomee.com'

Dir["#{ENV['HOME']}/Rails/conan/ym_gem/*/"].each do |directory_path|
  directory = directory_path.split("/").last
  inside(directory) do
    Dir["#{ENV['HOME']}/Rails/conan/ym_gem/#{directory}/**/*.*"].each do |file_path|
      file_name = file_path.sub("#{ENV['HOME']}/Rails/conan/ym_gem/#{directory}/", '').sub('gem_name', @name)
      if (file_directory = file_name.split("/").first(file_name.split("/").size-1).join("/")).present?
        run("mkdir -p #{file_directory}")
      end
      if file_name.match(/^assets/)
        run("cp #{file_path} #{file_name}")
      else
        file_text = File.read(file_path)
        open(file_name, "w") do |file|
          file << file_text.gsub(/\$GemName/, @name.camelize).gsub(/\$gem_name/, @name.underscore).gsub(/\$GEM_NAME/, @name.humanize.upcase).gsub(/\$Gem_name/, @name.humanize)
        end
      end
    end
  end
end

inside(".") do
  
  run("cp #{ENV['HOME']}/Rails/conan/ym_gem/gitignore .gitignore")
  run("cp #{ENV['HOME']}/Rails/conan/ym_gem/Guardfile .")
  
  open(".ruby-version", "w") do |file|
    file << "1.9.2"
  end
  
  file_text = File.read("#{@name}.gemspec")
  open("#{@name}.gemspec", 'w') do |file|
    file << file_text.gsub(/end$/, "  s.add_dependency 'ym_core', '~> 1.0'\n")
    file << "  s.add_development_dependency 'rspec-rails'\n"
    file << "  s.add_development_dependency 'factory_girl_rails'\n"
    file << "  s.add_development_dependency 'shoulda-matchers'\n"
    file << "  s.add_development_dependency 'capybara', '~> 1.1.0'\n"
    file << "  s.add_development_dependency 'guard-rspec'\n"
    file << "  s.add_development_dependency 'geminabox'\n"
    file << "  s.add_development_dependency 'ym_tools', '~> 1.0.0'\n"
    file << "  s.add_development_dependency 'listen', '~> 1.3.1'\n"
    file << "  s.add_development_dependency 'capybara-webkit'\n"
    file << "  s.add_development_dependency 'database_cleaner'\n"
    file << "end"
  end
end

inside("lib") do
  file_text = File.read("#{@name}.rb")
  open("#{@name}.rb", "w") do |file|
    file << "require 'ym_core'\n"
    file << file_text
  end
end