module Mandrake
  module Type
    # Type class for Float values, based on the built-in Ruby Float
    #
    # @!attribute [r] incremented_by
    #   @return [Float] The amount the base value was incremented by
  	class Float < Numeric

      attr :incremented_by


      # Sets default increment to 0.0, then passes all args to {Mandrake::Type::Base#initialize}
      def initialize(*)
        @incremented_by = 0.0
        super
      end


      # Increment the current value by given amount
      #
      # @raise [ArgumentError] If amount is not Float
      #
      # @param [Float, NilClass] amount The amount to increment by
      #
      # @return [Float] The current increment
      def increment(amount = 1.0)
        amount ||= 1.0
        raise ArgumentError, "The increment has to be a Float, #{amount.class.name} given" unless amount.is_a?(::Float)
        @value += amount
        @incremented_by += amount
      end

      alias_method :inc, :increment


      # Sets new value. Falls back to nil if value provided is nil, or if it is not
      # (and can't be converted to) Float.
      #
      # @note Setting a new value will reset the current {#incremented_by} value
      #
      # @param [Float] val The new value
      #
      # @return [Float] The updated value
      def value=(val)
        @incremented_by = 0.0
        @value = if val.nil? then nil
                 elsif val.respond_to?(:to_f) then val.to_f
                 else nil
                 end
      end
    end
	end
end