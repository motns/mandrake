module Mandrake
  module Type
  	class Float < Numeric

      attr :incremented_by

      def initialize(*)
        @incremented_by = 0.0
        super
      end

      def increment(amount = nil)
        amount ||= 1.0
        raise "The increment has to be a Float, #{amount.class.inspect} given" unless amount.is_a?(::Float)
        @value += amount
        @incremented_by += amount
      end

      alias_method :inc, :increment

      def value=(val)
        @value = val.nil? ? nil : val.to_f
      end
    end
	end
end