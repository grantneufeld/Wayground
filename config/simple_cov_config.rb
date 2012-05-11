require 'simplecov'
SimpleCov.start do
  add_filter "/app/models/test_model.rb" # comment this line out if you want to test the testing system
  add_filter "/config/"
  add_filter "/coverage/"
  add_filter "/db/"
  add_filter "/doc/"
  add_filter "/features/"
  add_filter "/public/"
  add_filter "/spec/"
  add_filter "/test/"
  add_filter "/tmp/"
  add_filter "/vendor/"

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Libraries", "lib"
  #add_group "Plugins", "vendor/plugins"
  add_group "Long files" do |src_file|
    src_file.lines.count > 100
  end
  add_group "Short files" do |src_file|
    src_file.lines.count < 5
  end
end

SimpleCov.at_exit do
  SimpleCov.result.format!
  path = 'coverage/percentage.txt'
  if File.exist?(path)
    f = File.open(path, 'w')
  else
    f = File.new(path, 'w')
  end
  f.write SimpleCov.result.covered_percent.to_s
  f.close
end
