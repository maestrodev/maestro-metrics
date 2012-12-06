require 'rake/clean'
require 'rspec/core/rake_task'

$:.push File.expand_path("../lib", __FILE__)

task :default => [:bundle, :spec]

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  t.rspec_opts = "--fail-fast --format p --color"
  # Put spec opts in a file named .rspec in root
end

desc "Get dependencies with Bundler"
task :bundle do
  system "bundle package"
end
