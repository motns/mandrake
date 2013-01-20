require 'bigdecimal'

module Mandrake
  module Type
  	class Decimal < Numeric

      attr :incremented_by

      def initialize(*)
        @incremented_by = BigDecimal("0.0")
        super
      end

      def increment(amount = nil)
        original_class = amount.class.inspect

        amount = if amount.nil? then BigDecimal("1.0")
                 elsif amount.is_a?(::BigDecimal) then amount
                 elsif amount.is_a?(::Float) || amount.is_a?(::Integer) then BigDecimal(amount.to_s)
                 else nil
                 end

        raise "The increment has to be a BigDecimal, Float or Integer - #{original_class} given" if amount.nil?

        @value += amount
        @incremented_by += amount
      end

      alias_method :inc, :increment

      def value=(val)
        @value = if val.nil? then nil
                 elsif val.is_a?(::BigDecimal) then val
                 elsif val.is_a?(::Float) || val.is_a?(::Integer) then BigDecimal(val.to_s)
                 else
                   # @TODO - we should put a notice in the logs
                   nil
                 end
      end
    end
	end
end