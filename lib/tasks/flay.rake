namespace :flay do
  dirs = %w(app lib features spec)
  desc "Analyze for code duplication in: #{dirs.join(', ')}"
  task :run do
    require "flay"
    flay = Flay.new
    flay.process(*Flay.expand_dirs_to_files(dirs))
    flay.report
  end
end

desc 'Alias for flay:run'
task :flay => 'flay:run'
