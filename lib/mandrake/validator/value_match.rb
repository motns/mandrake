module Mandrake
  module Validator
    class ValueMatch < Base

      @error_codes = {
        :no_match => "must be the same"
      }

      @inputs = 2

      protected
        def self.run_validator(value1, value2, params={})
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