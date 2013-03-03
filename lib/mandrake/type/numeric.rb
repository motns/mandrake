module Mandrake
  module Type
    # This is just a base Type that all Numeric classes (Integer, Float, etc.)
    # inherit from. You'd never actually use the Numeric Type class directly.
    class Numeric < Base
      # Default parameters for this Type, processed by {Mandrake::Type::Base.params}.
      PARAMS = {:in => nil}


      # Determine whether the value was modified by the setter, or one of the modifiers
      #
      # @return (see Mandrake::Type::Base#changed_by)
      def changed_by
        return :setter if @initial_value.nil? || @value.nil? || @value == @initial_value

        # the value was clearly altered, now let's see how

        base_value = @value
        base_value -= @incremented_by

        return :modifier if base_value == @initial_value
        return :setter
      end
    end
  end
end