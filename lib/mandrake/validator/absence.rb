module Mandrake
  module Validator
    class Absence < Base

      @error_codes = {
        :present => "must be absent"
      }

      protected
        def self.run_validator(value, params={})
          if value.nil? || (value.respond_to?(:empty?) && value.empty?)
            true
          else
            set_error :present
            false
          end
        end
      # end Protected
    end
  end
end