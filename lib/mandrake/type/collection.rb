require 'set'

module Mandrake
  module Type
    # Base class for collection types (Array, Set), with added functionality
    # for tracking elements that were added and removed.
    #
    # @note If you use a modifier and then set a new value (via #value=), the
    #    effect of the modifier will be lost. See code example below.
    #
    # @example First using a modifier, and then setting a new value
    #
    #    array = Mandrake::Type::Array.new([])
    #    array.push(4)
    #    array.value # => [4]
    #    array.added # => [4]
    #
    #    array.value = [5, 6]
    #    array.value # => [5 ,6]
    #    array.added # => []
    #    # Note how the diff was reset (the same will happen with #remove)
    #
    #
    # @!attribute [r] added
    #   @return [Array] Elements added to base set
    #
    # @!attribute [r] removed
    #   @return [Array] Elements removed from base set
    #
    class Collection < Base

      attr :added, :removed


      # Reset the @added and @removed variables used to track changes to the
      # Array or Set
      #
      # @return [void]
      def reset_diff
        @added = [] # Keep as Array, because the order is important
        @removed = ::Set.new
      end


      # Remove given value(s) from list
      #
      # @param args One or more values to remove
      def pull(*args)
        args.each do |val|
          @added.delete(val)

          # @removed is only for items which we'll remove when the Model is
          # persisted
          unless @initial_value.nil?
            @removed << val if @initial_value.include?(val)
          end

          unless @value.nil?
            @value.delete(val)
          end
        end
      end
    end
  end
end