# lib/tasks/rcov.rake
#
# Rake task for running Rcov, aggregating Rspec and Cucumber results.
#
# Run both the Rspec and Cucumber tests through Rcov and generate a merged result:
# > rake rcov
#
# To run Rcov for just one of those, use the applicable rcov task:
# > rake spec:rcov
# > rake cucumber:rcov
# 
# Was originally based on:
# http://gist.github.com/231022
# From http://github.com/jaymcgavren
#
# But now is almost completely different.

require "rspec/core/rake_task"
namespace :rcov do
	RSpec::Core::RakeTask.new :rspec_run do |t|
		t.rcov = true
		t.rcov_opts =  %[-Ilib -Ispec --exclude "osx/objc,gems/*,features,spec"]
		t.rcov_opts << %[--no-html --aggregate coverage.data]
	end
end

desc "Run specs and/or features to generate aggregated coverage"
task :rcov do |t|
	rm "coverage.data" if File.exist?("coverage.data")
	Rake::Task["rcov:rspec_run"].invoke #if has_rspec
	Rake::Task["cucumber:rcov"].invoke #if has_cucumber
end
