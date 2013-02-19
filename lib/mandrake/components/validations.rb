module Mandrake
  # Used to add methods for creating and running {Mandrake::ValidationChain} items
  # to validate the data in a {Mandrake::Model} instance.
  module Validations

    # Returns whether or not this {Mandrake::Model} instance has been validated
    # with the current data.
    #
    # @note This is currently not implemented
    # @todo Use some sort of observer pattern to hook this into attribute changes
    #
    # @return [TrueClass, FalseClass]
    def validated
      @validated ||= false
    end


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
      run_validations
      failed_validators.list.empty?
    end


    # Run the main validation chain for this {Mandrake::Model} instance
    #
    # @return [TrueClass, FalseClass]
    def run_validations
      failed_validators.clear
      validation_chain.run(self)
    end
    protected :run_validations


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

    # Load in Class methods
    def self.included(base)
      base.extend ClassMethods
    end
  end
end