FileUtils::mkdir_p "#{shared_path}/dragonfly"
FileUtils::mkdir_p "#{release_path}/data"
run "ln -s #{shared_path}/dragonfly #{release_path}/data/dragonfly"