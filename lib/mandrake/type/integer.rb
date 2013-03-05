module Mandrake
  module Type
    # Type class for Integer values, based on the built-in Ruby Integer (Fixnum, Bignum)
    #
    # @!attribute [r] incremented_by
    #   @return [Fixnum] The amount the base value was incremented by
    class Integer < Numeric

      attr :incremented_by


      # Increment the current value by given amount
      #
      # @raise [ArgumentError] If amount is not an Integer
      #
      # @param [Integer, NilClass] amount The amount to increment by
      #
      # @return [Integer] The current increment
      def increment(amount = 1)
        amount ||= 1
        raise "The increment has to be an Integer, #{amount.class.inspect} given" unless amount.is_a?(::Integer)
        @value += amount
        @incremented_by += amount
      end

      alias_method :inc, :increment


      # Sets new value. Falls back to nil if value provided is nil, or if it is not
      # (and can't be converted to) Integer.
      #
      # @note Setting a new value will reset the current {#incremented_by} value
      #
      # @param [Integer] val The new value
      #
      # @return [Integer] The updated value
      def value=(val)
        @incremented_by = 0
        @value = if val.nil? then nil
                 elsif val.respond_to?(:to_i) then val.to_i
                 else nil
                 end
      end
    end
	end
end