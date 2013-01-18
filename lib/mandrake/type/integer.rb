module Mandrake
  module Type
  	class Integer < Numeric

      attr :incremented_by

      def initialize(*)
        @incremented_by = 0
        super
      end

      def increment(amount = nil)
        amount ||= 1
        raise "The increment has to be an Integer, #{amount.class.inspect} given" unless amount.is_a?(::Integer)
        @value += amount
        @incremented_by += amount
      end

      alias_method :inc, :increment

      def value=(val)
        @value = val.nil? ? nil : val.to_i
      end
    end
	end
end