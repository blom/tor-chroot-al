require "rake/clean"
require "rake/testtask"

task(:default)
CLEAN.include("chroot")

Rake::TestTask.new do |t|
  t.libs       = %w(test)
  t.test_files = FileList["test/*_test.rb"]
end
