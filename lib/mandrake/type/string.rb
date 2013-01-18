module Mandrake
  module Type
  	class String < Base
      param length: 50, format: nil

      def value=(val)
        @value = val.nil? ? nil : val.to_s
      end
    end
	end
end