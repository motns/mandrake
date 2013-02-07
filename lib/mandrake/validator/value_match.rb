module Mandrake
  module Validator
    class ValueMatch < Base

      @error_codes = {
        :no_match => "must be the same"
      }

      @inputs = 2

      protected
        def self.run_validator(value1, value2, params={})
          return true if value1.nil? && value2.nil?

          if value1 === value2
            true
          else
            set_error :no_match
            false
          end
        end
      # end Protected
    end
  end
end