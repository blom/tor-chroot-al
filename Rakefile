require "rubygems"
require "bundler/setup"
require "rake/clean"
require "rake/testtask"
require "yard"

task(:default)
CLEAN.include(".yardoc", "chroot", "doc")

Rake::TestTask.new :test do |t|
  t.libs       = %w(test)
  t.test_files = Dir["test/**/*_test.rb"]
end

YARD::Rake::YardocTask.new :yard do |t|
  t.options = %w(-mmarkdown -odoc -rREADME.md)
end
