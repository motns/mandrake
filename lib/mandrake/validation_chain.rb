module Mandrake
  # Used to create a chain consisting of {Mandrake::Validation} and {Mandrake::ValidationChain} items,
  # which will be executed in order. Validation chains are run against a {Mandrake::Model} instance,
  # with each item evaluated one at a time until a failure is encountered, or there are no more
  # items left in the chain.
  # You may use the *:continue_on_failure* setting to change the default behaviour, and not
  # stop chain execution if an item fails.
  #
  # A chain may have a set of *conditions*, which are essentially {Mandrake::Validator} classes
  # validating one or more attributes. If the validator returns true, the chain gets
  # executed. If it returns false, items in the chain will not be executed, and the
  # chain will simply return true.
  #
  # @!attribute [r] continue_on_failure
  #   @return [Boolean] Whether to continue chain execution if an item returns false
  #
  # @!attribute [r] items
  #   @return [Array] A list of {Mandrake::Validation} and {Mandrake::ValidationChain} items to execute in this chain
  #
  # @!attribute [r] conditions
  #   @return [Array] A list of {Mandrake::Validator} and attribute pairs to check before running the chain
  class ValidationChain

    attr :continue_on_failure, :items, :conditions

    # @param [Hash] params Config options
    # @option params [Boolean] :continue_on_failure (false) Whether to continue
    #   chain execution if an item returns false
    # @option params [Symbol, Array] :if_present Add condition to only run chain
    #   if the given attributes pass the {Mandrake::Validator::Presence Presence} validator
    # @option params [Symbol, Array] :if_absent Add condition to only run chain
    #   if the given attributes pass the {Mandrake::Validator::Absence Absence} validator
    #
    # @yield Executes a given block in the context of the instance, allowing you to
    #   add {Mandrake::Validator Validator} and {Mandrake::ValidationChain ValidationChain} items in a nice
    #   DSL-like syntax
    #
    # @return [ValidationChain]
    #
    # @example Create new chain with some validations
    #   Mandrake::ValidationChain.new(continue_on_failure: true) do
    #     validate :Presence, :title
    #     validate :Length, :title, length: 1..50
    #   end
    #
    def initialize(params = {}, &block)
      @continue_on_failure = params[:continue_on_failure] ? params[:continue_on_failure] : false

      @conditions = []
      generate_conditions(params)

      @items = []

      instance_eval(&block) if block_given?
    end


    # Add a new {Mandrake::Validation} instance to this chain
    #
    # @overload validate(validator, attribute)
    #   Create a validation with one attribute and no params
    #   @param [Symbol, String] validator The name of the {Mandrake::Validator} to use
    #   @param [Symbol, String] attribute The name of the attribute to validate
    #
    # @overload validate(validator, attribute1, attribute2)
    #   Create a validation with a validator that takes multiple attributes and no params
    #   @param [Symbol, String] validator The name of the {Mandrake::Validator} to use
    #   @param [Symbol, String] attribute1 The name of the first attribute argument
    #   @param [Symbol, String] attribute2 The name of the second attribute argument
    #
    # @overload validate(validator, attribute, params = {})
    #   Create a validation with one attribute and the given params
    #   @param [Symbol, String] validator The name of the {Mandrake::Validator} to use
    #   @param [Symbol, String] attribute The name of the attribute to validate
    #   @param [Hash] params The list of params to pass to the validator
    #
    # @return [Mandrake::Validation]
    #
    # @example Add new validation to chain
    #    Mandrake::ValidationChain.new.validate :Length, :name, 1..10
    #
    def validate(validator, *args)
      add Mandrake::Validation.new(validator, *args)
    end


    # Add a new {Mandrake::ValidationChain} instance to this chain
    #
    # @param (see #initialize)
    # @option (see #initialize)
    # @yield (see #initialize)
    # @return (see #initialize)
    #
    # @example Add new chain with some validations
    #   Mandrake::ValidationChain.new.chain(continue_on_failure: true) do
    #     validate :Presence, :title
    #     validate :Length, :title, length: 1..50
    #   end
    #
    def chain(params = {}, &block)
      add Mandrake::ValidationChain.new(params, &block)
    end


    # Syntactic sugar for adding a new {Mandrake::ValidationChain} instance to this chain
    # with the :if_present parameter set with one or more attributes
    #
    # @overload if_present(attribute, params = {})
    #   Test one attribute, and pass given params to new chain
    #   @param [String, Symbol] attribute The attribute to test
    #   @param [Hash] params Chain config options
    #
    # @overload if_present(attribute1, attribute2, params = {})
    #   Test multiple attributes, and also pass given params to new chain
    #   @param [String, Symbol] attribute1 The first attribute to test
    #   @param [String, Symbol] attribute2 The second attribute to test
    #   @param [Hash] params Chain config options
    #
    # @yield (see #initialize)
    # @return (see #initialize)
    #
    # @example Add new chain with conditional and some validation
    #   Mandrake::ValidationChain.new.if_present :title do
    #     validate :Length, :title, length: 1..50
    #   end
    #
    def if_present(*args, &block)
      attributes, params = Mandrake::extract_params(*args)
      params = {:if_present => attributes}
      chain(params, &block)
    end


    # Syntactic sugar for adding a new {Mandrake::ValidationChain} instance to this chain
    # with the :if_absent parameter set with one or more attributes
    #
    # @overload if_absent(attribute, params = {})
    #   Test one attribute, and pass given params to new chain
    #   @param [String, Symbol] attribute The attribute to test
    #   @param [Hash] params Chain config options
    #
    # @overload if_absent(attribute1, attribute2, params = {})
    #   Test multiple attributes, and also pass given params to new chain
    #   @param [String, Symbol] attribute1 The first attribute to test
    #   @param [String, Symbol] attribute2 The second attribute to test
    #   @param [Hash] params Chain config options
    #
    # @yield (see #initialize)
    # @return (see #initialize)
    #
    # @example Add new chain with conditional and some validation
    #   Mandrake::ValidationChain.new.if_absent :username do
    #     validate :Presence, :name
    #   end
    #
    def if_absent(*args, &block)
      attributes, params = Mandrake::extract_params(*args)
      params = {:if_absent => attributes}
      chain(params, &block)
    end


    # Add one or more items to the validation chain
    #
    # @overload add(item)
    #   Add a single item to the chain
    #   @param [Mandrake::Validation, Mandrake::ValidationChain] item Item to add to the chain
    #
    # @overload add(item1, item2)
    #   Add multiple items to the chain (you can put down as many as you like)
    #   @param [Mandrake::Validation, Mandrake::ValidationChain] item1 First item to add to the chain
    #   @param [Mandrake::Validation, Mandrake::ValidationChain] item2 Second item to add to the chain
    #
    # @return [Mandrake::Validation, Mandrake::ValidationChain] The last item added to the chain
    #
    # @raise [ArgumentError] If one of the items passed in is neither a Validation nor a ValidationChain
    #
    # @example Add multiple items to chain
    #   validation1 = Mandrake::Validation.new(:Presence, :title)
    #   validation2 = Mandrake::Validation.new(:Presence, :name)
    #
    #   Mandrake::ValidationChain.new.add validation1, validation2
    #
    def add(*items)
      items.each do |item|
        unless item.is_a?(::Mandrake::Validation) || item.is_a?(::Mandrake::ValidationChain)
          raise ArgumentError, "Validator chain item has to be a Validator or another ValidationChain, #{item.class.name} given"
        end

        @items << item
      end

      items.last
    end


    # Execute the validation chain against the given {Mandrake::Model} instance
    #
    # @param [Mandrake::Model] document
    #
    # @return [Boolean] Returns True if the chain conditions weren't met, or if
    #   all the chain items have returned True. False otherwise.
    #
    def run(document)
      return true unless conditions_met?(document)

      success = true

      @items.each do |item|
        validation_success = item.run(document)
        success = success && validation_success
        break unless @continue_on_failure || success
      end

      success
    end


    protected

      # Transform the parameters passed to the constructor into a list of hashes
      # in the following format:
      #
      # {
      #    :validator => Mandrake::Validator,
      #    :attribute => :attribute_name
      # }
      #
      # and store them in the @conditions instance variable
      #
      # @params [Hash] params
      # @option params [Symbol, Array] :if_present Add condition to only run chain
      #   if the given attributes pass the {Mandrake::Validator::Presence Presence} validator
      # @option params [Symbol, Array] :if_absent Add condition to only run chain
      #   if the given attributes pass the {Mandrake::Validator::Absence Absence} validator
      #
      # @return [void]
      def generate_conditions(params)
        if params.key? :if_present
          if params[:if_present].respond_to?(:to_sym) # single field
            @conditions << {
              :validator => ::Mandrake::Validator::Presence,
              :attribute => params[:if_present]
            }
          elsif params[:if_present].is_a?(Array)
            params[:if_present].each do |attribute|
              @conditions << {
                :validator => ::Mandrake::Validator::Presence,
                :attribute => attribute
              }
            end
          end
        end

        if params.key? :if_absent
          if params[:if_absent].respond_to?(:to_sym) # single field
            @conditions << {
              :validator => ::Mandrake::Validator::Absence,
              :attribute => params[:if_absent]
            }
          elsif params[:if_absent].is_a?(Array)
            params[:if_absent].each do |attribute|
              @conditions << {
                :validator => ::Mandrake::Validator::Absence,
                :attribute => attribute
              }
            end
          end
        end
      end



      # Test the defined confitions against a given {Mandrake::Model} instance
      #
      # @note It is currently possible to put conflicting conditions in place, like
      #   an :if_present and :if_absent clause with the same attribute. Basically,
      #   we'll let people shoot themselves in the foot, if they so please. If this
      #   becomes a problem, we can start putting more validation in here, but for now
      #   I prefer to keep things simple.
      #
      # @param [Mandrake::Model] document The document to test with
      #
      # @return [Boolean] returns True if all conditions were met, or if there are
      #   no conditions defined. False otherwise.
      #
      def conditions_met?(document)
        return true if @conditions.empty?

        @conditions.each do |condition|
          return false unless condition[:validator].validate(document.read_attribute(condition[:attribute]))
        end

        true
      end

    # end protected
  end
end