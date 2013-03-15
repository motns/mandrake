module Mandrake
  # Used to add methods for creating and running {Mandrake::ValidationChain} items
  # to validate the data in a {Mandrake::Model} instance.
  module Validations
    extend ActiveSupport::Concern

    included do |base|
      base.define_model_callbacks :validation, only: [:before, :after]
      base.after_attribute_change { |doc| doc.reset_validated }
    end


    # Returns whether or not this {Mandrake::Model} instance has been validated
    # with the current data.
    #
    # @return [TrueClass, FalseClass]
    def validated?
      @validated ||= false
    end


    # Reset the value for @validated to False - this will force all the validations
    # to be executed, the next time {#valid?} is called
    def reset_validated
      @validated = false
    end

    protected :validated?, :reset_validated


    # Returns the {Mandrake::FailedValidators} instance for the current {Mandrake::Model} instance
    #
    # @return [Mandrake::FailedValidators]
    def failed_validators
      @failed_validators ||= Mandrake::FailedValidators.new
    end


    # Shortcut for getting the main {Mandrake::ValidationChain} for the current {Mandrake::Model} class
    #
    # @return [Mandrake::ValidationChain]
    def validation_chain
      self.class.validation_chain
    end


    # Runs validations and returns a Boolean indicating whether the current {Mandrake::Model}
    # instance data is valid
    #
    # @return [TrueClass, FalseClass]
    def valid?
      run_validations unless validated?
      failed_validators.list.empty?
    end


    # Run the main validation chain for this {Mandrake::Model} instance
    #
    # @return [TrueClass, FalseClass]
    def run_validations
      run_callbacks :validation do
        failed_validators.clear
        validation_chain.run(self)
        # @todo Run validations for embedded documents here, then include failed_validators
        @validated = true
      end
    end
    protected :run_validations


    # Methods to extend the class we're included in
    module ClassMethods
      # Returns the {Mandrake::ValidationChain} for the current {Mandrake::Model} class
      #
      # @return [Mandrake::ValidationChain]
      def validation_chain
        @validation_chain ||= Mandrake::ValidationChain.new
      end


      # Returns the {Mandrake::ValidationChain} used specifically to validate attributes
      # in the current {Mandrake::Model} class. This chain is part of the main validation
      # chain, but can be accessed directly so we can keep adding validation chains
      # for each newly defined key.
      #
      # @return [Mandrake::ValidationChain]
      def attribute_chain
        return @attribute_chain if defined?(@attribute_chain)
        @attribute_chain = validation_chain.chain(continue_on_failure: true)
      end


      # Proxies to main validation chain
      # @see Mandrake::ValidationChain#validate
      def validate(validator, *args); validation_chain.validate(validator, *args); end

      # Proxies to main validation chain
      # @see Mandrake::ValidationChain#chain
      def chain(params = {}, &block); validation_chain.chain(params, &block); end

      # Proxies to main validation chain
      # @see Mandrake::ValidationChain#if_present
      def if_present(params = {}, &block); validation_chain.if_present(params, &block); end

      # Proxies to main validation chain
      # @see Mandrake::ValidationChain#if_absent
      def if_absent(params = {}, &block); validation_chain.if_absent(params, &block); end


      # Creates a {Mandrake::ValidationChain} in the {#attribute_chain} for a newly
      # defined key. It looks at key parameters, and sets up the appropriate
      # {Mandrake::Validator} items.
      #
      # @param [Mandrake::Key] key
      # @return [void]
      def create_validations_for(key)
        key_name = key.name
        key_params = key.params

        # Skip the chain if a non-required key is empty
        params = key.required ? {} : {:if_present => key_name}

        attribute_chain.chain(params) do
          validate :Presence, key_name if key.required
          validate :Format, key_name, format: key_params[:format] if key_params[:format]
          validate :Length, key_name, length: key_params[:length] if key_params[:length]
          validate :Inclusion, key_name, in: key_params[:in] if key_params[:in]
          validate :Exclusion, key_name, not_in: key_params[:not_in] if key_params[:not_in]
        end
      end
    end
  end
end