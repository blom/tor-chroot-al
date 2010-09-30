%w(etc shell test/unit).each { |f| require f }

class Test::Unit::TestCase
  class << self
    def current_context
      @@current_context ||= []
    end

    def context(context_name)
      current_context.push "_" + context_name.to_s.downcase.gsub(/\s+/, "_")
      yield
      current_context.pop
    end

    def it(test_name)
      test_name = test_name.downcase.gsub(/\s+/, "_")
      define_method("test#{current_context.join}_#{test_name}", Proc.new)
    end
  end
end
