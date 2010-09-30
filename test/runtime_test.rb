require "test_helper"

class RuntimeTest < Test::Unit::TestCase
  context "build script" do
    it "is running on arch linux" do
      assert File.exist? "/etc/arch-release"
      assert Shell.new.find_system_command "pacman"
    end

    it "is not running as superuser" do
      assert_not_equal 0, Process.uid
    end
  end

  context "tor" do
    it "should be installed as an arch package" do
      `pacman -Q tor`
      assert_equal 0, $?
    end

    it "should be a system user" do
      assert Etc.getpwnam "tor"
    end

    it "should be a system group" do
      assert Etc.getgrnam "tor"
    end
  end
end
