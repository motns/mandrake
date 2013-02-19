module Mandrake
  # Used to represent a single key in a {Mandrake::Model} class. When a Model
  # class is instantiated, the {#create_attribute} method is used to create
  # an attribute object, which is basically an instance of the {Mandrake::Type} for the key.
  #
  # @!attribute [r] name
  #   @return [Symbol] The name of the key
  #
  # @!attribute [r] alias
  #   @return [Symbol] The alias for the key
  #
  # @!attribute [r] type
  #   @return [Symbol] The name of the {Mandrake::Type} for the key
  #
  # @!attribute [r] params
  #   @return [Hash] Optional parameters for the key
  #
  class Key
    attr :name, :alias, :type, :params


    # @param [String, Symbol] name The name of the new key
    # @param [String, Symbol] type The name of the {Mandrake::Type} of this key
    # @param [Hash] opt Optional key settings - most of these will be processed
    #    by the {Mandrake::Type}, so see the documentation for those for all accepted options
    #
    # @option opt [String, Symbol] :as Define an alias for this key - defaults to key name
    #
    # @return [void]
    def initialize(name, type, opt = {})
      @name = name.to_sym
      @alias = (opt[:as] || name).to_sym
      @type = type

      @params = {}
      @params[:required] = opt[:required] || false
      @params[:default] = opt[:default] || nil

      raise ArgumentError, "Key type should be provided as a Symbol, #{@type.class.name} given" unless @type.respond_to?(:to_sym)

      @klass = Mandrake::Type.get_class(@type)
      raise "Unknown Mandrake type: #{@type}" if @klass.nil?

      @klass.params.each do |param, default|
        @params[param] = opt[param] || default
      end
    end


    # Shortcut for getting the value of the :required  parameter
    #
    # @return [Boolean] Whether this Key is required
    def required
      @params[:required]
    end


    # Shortcut for getting the value of the :default  parameter
    #
    # @return [Object, NilClass] The default value for this key
    def default
      @params[:default]
    end


    # Factory for returning an instance of the defined {Mandrake::Type}
    #
    # @param value The value to use when initializing
    # @return [Mandrake::Type]
    def create_attribute(value)
      @klass.new(value)
    end
  end
end