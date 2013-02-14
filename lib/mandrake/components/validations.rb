module Mandrake
  module Validations

    # @TODO - implement this with some sort of observer pattern, watching attribute changes
    #
    # # store validation state
    # def validated
    #   @validated ||= false
    # end

    def failed_validators
      @failed_validators ||= Mandrake::FailedValidators.new
    end

    def validation_chain
      self.class.validation_chain
    end


    def valid?
      run_validations
      failed_validators.list.empty?
    end


    def run_validations
      failed_validators.clear
      validation_chain.run(self)
    end
    protected :run_validations


    module ClassMethods

      def validation_chain
        @validation_chain ||= Mandrake::ValidationChain.new
      end

      def attribute_chain
        return @attribute_chain if defined?(@attribute_chain)
        @attribute_chain = validation_chain.chain(continue_on_failure: true)
      end


      # Proxy to main validation chain
      def validate(validator, *args); validation_chain.validate(validator, *args); end
      def chain(params = {}, &block); validation_chain.chain(params, &block); end
      def if_present(params = {}, &block); validation_chain.if_present(params, &block); end
      def if_absent(params = {}, &block); validation_chain.if_absent(params, &block); end


      def create_validations_for(key)
        # Skip the chain if a non-required key is empty
        params = key.required ? {} : {:if_present => key.name}

        attribute_chain.chain(params) do
          validate :Presence, key.name if key.required
          validate :Format, key.name, format: key.params[:format] if key.params[:format]
          validate :Length, key.name, length: key.params[:length] if key.params[:length]
          validate :Inclusion, key.name, in: key.params[:in] if key.params[:in]
          validate :Exclusion, key.name, not_in: key.params[:not_in] if key.params[:not_in]
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end