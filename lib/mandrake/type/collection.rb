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
    #    array.add(4)
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

      # Sets @added and @removed to [], then passes all args to {Mandrake::Type::Base#initialize}
      def initialize(*)
        @added = []
        @removed = []
        super
      end
    end
  end
end