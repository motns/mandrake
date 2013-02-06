module Mandrake
  module Validations
    module ClassMethods
      def create_validations(key)
        #validates_presence_of key.name if key.required
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def failed_validators
      @failed_validators ||= Mandrake::FailedValidators.new
    end
  end
end