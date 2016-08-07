begin
  require 'flay'

  namespace :flay do
    app_dirs = %w(app lib)
    desc "Analyze for code duplication in: #{app_dirs.join(', ')}"
    task :app do
      require 'flay'
      flay = Flay.new
      flay.process(*Flay.expand_dirs_to_files(app_dirs))
      flay.report
    end

    spec_dirs = %w(spec)
    desc "Analyze for code duplication in: #{spec_dirs.join(', ')}"
    task :spec do
      require 'flay'
      flay = Flay.new
      flay.process(*Flay.expand_dirs_to_files(spec_dirs))
      flay.report
    end

    features_dirs = %w(features)
    desc "Analyze for code duplication in: #{features_dirs.join(', ')}"
    task :features do
      require 'flay'
      flay = Flay.new
      flay.process(*Flay.expand_dirs_to_files(features_dirs))
      flay.report
    end
  end

  desc 'Alias for flay:app'
  task flay: 'flay:app'

rescue LoadError
end
