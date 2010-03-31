require File.expand_path("../test_helper", __FILE__)

class EnvironmentTest < Test::Unit::TestCase
  def setup
    @shell = Shell.new
  end

  it "should not run as superuser" do
    assert_not_equal 0, Process.uid
  end

  it "should run on arch linux" do
    assert File.exist?("/etc/arch-release") &&
           @shell.find_system_command("pacman")
  end
end
