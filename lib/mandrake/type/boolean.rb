module Mandrake
  module Type
  	class Boolean < Base
      def value=(val)
        @value = val.nil? ? nil : !!val
      end
    end
  end
end