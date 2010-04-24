require "test_helper"

class TorTest < Test::Unit::TestCase
  it "should be installed as an arch package" do
    %x(pacman -Q tor)
    assert_equal 0, $?
  end

  it "should have a tor user" do
    assert Etc.getpwnam "tor"
  end

  it "should have a tor group" do
    assert Etc.getgrnam "tor"
  end
end
