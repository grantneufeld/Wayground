namespace :brakeman do

  desc "Run Brakeman"
  task :run, :output_file do |t, args|
    require 'brakeman'
    output_file = args[:output_file]
    if output_file.is_a? String
      output_files = [output_file]
    else
      output_files = output_file
    end
    output_files = ['brakeman.html'] if (output_files.nil? || output_files.size == 0)
    Brakeman.run app_path: ".", output_files: output_files
  end

end

desc 'Alias for brakeman:run'
task :brakeman => 'brakeman:run'

