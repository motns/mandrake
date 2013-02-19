module Mandrake
  # Used to store detailed information on the validation failures for a {Mandrake::Model} instance.
  # Validation failures will be added by {Mandrake::Validation} items when the given validator
  # fails.
  #
  # Validation failures are stored in a hash of this format:
  #
  #   {
  #     :attribute_name => [
  #       {
  #         :validator => :Presence,
  #         :error_code => :missing,
  #         :message => "must be provided"
  #       }
  #     ],
  #     :model => [
  #       {
  #         :validator => :ValueMatch,
  #         :attributes => [:attribute1, :attribute2],
  #         :error_code => :no_match,
  #         :message => "must be the same"
  #       }
  #     ]
  #   }
  #
  # Simple validation failures for individual attributes are stores under the attribute name,
  # whereas complex validators (which take multiple values), will be stored under :model
  class FailedValidators
    # Creates an empty hash for storing validation failures
    def initialize
      @failed_validators = {}
    end


    # Record a new validation failure. Depending on the number of entries provided
    # under attributes, this will either be added under the attribute name, or under
    # :model if multiple attributes were involved.
    #
    # @param [Array] attributes The list of attributes that failed validation
    # @param [String, Symbol] validator_name The name of the {Mandrake::Validator} that failed validation
    # @param [String] message The error message
    # @param [Symbol] error_code The specific error code of this failure
    #
    # @return [void]
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


    # Clear the list of failed validators
    #
    # @return [void]
    def clear
      @failed_validators = {}
    end


    # Return hash with failed validators
    #
    # @return [Hash]
    def list
      @failed_validators
    end
  end
end