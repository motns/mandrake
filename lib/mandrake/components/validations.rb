module Mandrake
  module Validations

    # @TODO - implement this with some sort of observer pattern, watching attribute changes
    # store validation state
    # def validated
    #   @validated ||= false
    # end

    def failed_validators
      @failed_validators ||= Mandrake::FailedValidators.new
    end

    def validation_chains
      self.class.validation_chains
    end


    def valid?
      run_validations
      failed_validators.list.empty?
    end


    def run_validations
      failed_validators.clear
      success = true

      if validation_chains.key?(:attributes)
        validation_chains[:attributes].each do |attribute, chain|
          chain_success = chain.run(self)
          success = success && chain_success
        end
      end

      # Only run model validators if all attribute validators passed
      if validation_chains.key?(:model) && success
        chain_success = validation_chains[:model].run(self)
        success = success && chain_success
      end

      success
    end

    protected :run_validations


    module ClassMethods
      def validation_chains
        @validation_chains ||= {}
      end

      def create_validations(key)
        if key.required
          validate :Presence, key.name
        else
          validation_chains[:attributes] ||= {}
          validation_chains[:attributes][key.name] = Mandrake::ValidationChain.new(if_present: key.name)
        end

        validate :Format, key.name, format: key.params[:format] if key.params[:format]
        validate :Length, key.name, length: key.params[:length] if key.params[:length]
      end

      def validate(validator, *args)
        attributes, params = Mandrake::extract_params(*args)

        if attributes.size > 1 # complex validator
          validation_chains[:model] ||= Mandrake::ValidationChain.new
          validation_chains[:model].add(Mandrake::Validation.new(validator, *args))
        else # simple validator
          attribute = attributes[0]
          validation_chains[:attributes] ||= {}
          validation_chains[:attributes][attribute] ||= Mandrake::ValidationChain.new
          validation_chains[:attributes][attribute].add(Mandrake::Validation.new(validator, attribute, params))
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end