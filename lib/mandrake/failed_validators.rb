module Mandrake
  class FailedValidators
    def initialize
      @failed_validators = {}
    end

    def add(attributes, validator_name, message, error_code = nil)
      attributes = attributes.collect { |a| a.to_sym }

      # This is a Model-wide (multi-field) validator
      if attributes.size > 1
        @failed_validators[:model] ||= []

        @failed_validators[:model] << {
          :validator => validator_name,
          :attributes => attributes, # this is mostly for reflection/debugging
          :error_code => error_code,
          :message => message
        }
      else
        attribute = attributes[0]

        @failed_validators[attribute] ||= []

        @failed_validators[attribute] << {
          :validator => validator_name,
          :error_code => error_code,
          :message => message
        }
      end
    end

    def clear
      @failed_validators = {}
    end

    def list
      @failed_validators
    end
  end
end