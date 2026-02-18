require "bundler/gem_tasks"
require "rake/testtask"
require "standard"
require "standard/rake"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::Task[:standard].clear
task :standard do
  puts "Running StandardRB..."
  args = Standard::RakeSupport.argvify + ["--format", "progress"]
  exit_code = Standard::Cli.new(args).run
  fail unless exit_code == 0
  puts "StandardRB passed."
end

task default: %i[test standard]
