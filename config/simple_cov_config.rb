require 'simplecov'
SimpleCov.start do
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
	add_group "Long files" do |src_file|
		src_file.lines.count > 100
	end
	add_group "Short files" do |src_file|
		src_file.lines.count < 5
	end
end


