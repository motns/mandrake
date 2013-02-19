module Mandrake
  module Type
    # Type class for storing textual values. Lenght is restricted to 50 characters
    # by default, but this can be overridden. There are no default restrictions
    # on format.
  	class String < Base

      # Default parameters for this Type, processed by {Mandrake::Type::Base.params}
      PARAMS = {length: 0..50, format: nil}


      # Sets new value - nil is preserved, otherwise it casts into String via to_s
      #
      # @param val New value
      # @ return [String, nil] The updated value
      def value=(val)
        @value = if val.nil? then nil
                 else val.to_s
                 end
      end
    end
	end
end