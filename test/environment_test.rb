require "test_helper"

class EnvironmentTest < Test::Unit::TestCase
  it "should not run as superuser" do
    assert_not_equal 0, Process.uid
  end

  it "should run on arch linux" do
    assert File.exist?("/etc/arch-release")
    assert Shell.new.find_system_command("pacman")
  end
end
