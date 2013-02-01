module Mandrake
  module Validator
    class Presence < Base

      @error_codes = {
        :missing => "must be provided",
        :empty => "cannot be empty"
      }

      def self.run_validator(value, params={})
        if value.nil?
          set_error :missing
          false
        elsif value.respond_to?(:empty?) && value.empty?
          set_error :empty
          false
        else
          true
        end
      end
    end
  end
end