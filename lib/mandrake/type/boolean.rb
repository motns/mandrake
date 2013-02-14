module Mandrake
  module Type
    # Type class for storing Boolean values (shocking!)
  	class Boolean < Base
      # Sets new value - nil is preserved, otherwise it casts into TrueClass/FalseClass
      #
      # @param val New value
      # @ return [TrueClass, FalseClass, nil] The updated value
      def value=(val)
        @value = val.nil? ? nil : !!val
      end
    end
  end
end