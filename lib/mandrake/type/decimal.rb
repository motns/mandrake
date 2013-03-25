require 'bigdecimal'

module Mandrake
  module Type
    # Type class for Decimal values, based on Ruby's BigDecimal.
    #
    # @!attribute [r] incremented_by
    #   @return [BigDecimal] The amount the base value was incremented by
  	class Decimal < Numeric

      attr :incremented_by


      # Increment the current value by given amount, attempting to convert the
      # value if it's not a BigDecimal.
      #
      # @raise [ArgumentError] If amount is not BigDecimal, Float or Integer
      #
      # @param [BigDecimal, NilClass] amount The amount to increment by
      #
      # @return [BigDecimal] The current increment
      def increment(amount = BigDecimal("1.0"))
        original_class = amount.class.inspect

        amount = if amount.nil? then BigDecimal("1.0")
                 elsif amount.is_a?(::BigDecimal) then amount
                 elsif amount.is_a?(::Float) || amount.is_a?(::Integer) then BigDecimal(amount.to_s)
                 else nil
                 end

        raise ArgumentError, "The increment has to be a BigDecimal, Float or Integer - #{original_class} given" if amount.nil?

        @value += amount
        @incremented_by += amount
      end

      alias_method :inc, :increment


      # Set a new value, while attempting to convert values which aren't BigDecimal.
      # If it's not BigDecimal, Float or Integer, we'll set the value to nil, and
      # put a notice in the logs.
      #
      # @note Setting a new value will reset the current {#incremented_by} value
      #
      # @param [BigDecimal, Float, Integer] val The new value
      #
      # @return [BigDecimal, NilClass] The updated value
      def value=(val)
        @incremented_by = BigDecimal("0.0")

        @value = if val.nil? then nil
                 elsif val.is_a?(::BigDecimal) then val
                 elsif val.is_a?(::Float) || val.is_a?(::Integer) then BigDecimal(val.to_s)
                 else
                   # @TODO - we should put a notice in the logs
                   nil
                 end
      end
    end
	end
end