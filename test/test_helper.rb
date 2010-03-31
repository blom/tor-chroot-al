%w(etc shell test/unit).each { |f| require f }

class Test::Unit::TestCase
  def self.it(name, &block)
    name = name.downcase.gsub(/\W+/, "_")
    define_method("test_#{name}", block)
  end
end
