module Mandrake
  # Used to augment an arbitrary class with methods for defining a data schema,
  # with relevant validations for that schema. These classes can then be instantiated
  # to store data in the given format.
  #
  # @note Model classes have no persistence built into them.
  #   Persistence into a data store is handled by separate classes wrapping a Model.
  #
  # @!attribute [r] new_keys
  #   @return [Array<Symbol>] A list of key names that weren't present in the data
  #      that was used to initialize this Model instance.
  #
  # @!attribute [r] removed_keys
  #   @return [Array<Symbol>] A list of key names which aren't part of the defined schema,
  #       but were provided when the Model was initialized.
  #
  module Model

    attr :new_keys, :removed_keys


    # Additional modules to load in
    COMPONENTS = [
      Mandrake::Keys,
      Mandrake::Dirty,
      Mandrake::Validations
    ]


    # Load modules and class methods
    def self.included(base)
      COMPONENTS.each do |component|
        base.send :include, component
      end

      base.extend ClassMethods
    end


    # Methods to extend the class we're included in
    module ClassMethods
      # Used to create a Module for adding new methods to the Model class externally.
      # Having this as a Module means that the methods can be overridden later.
      #
      # @return [Module]
      def model_methods_module
        @model_methods_module ||= begin
          mod = Module.new
          include(mod)
          mod
        end
      end
    end


    # @note Be careful if your base class already has a constructor. if it does, make sure to call super().
    # @param [Hash] data The data to initialize the Model instance with
    def initialize(data = {})
      @attribute_objects = {}

      # New fields to write on next save
      @new_keys = []
      # Fields to remove on next save
      @removed_keys = data.keys


      # List of keys with defaults to process after
      # the rest of the data has been loaded
      post_process_defaults = []


      # Load data
      key_objects.each do |name, key|
        if data.key? key.alias # Data should be stored under the alias...
          initialize_attribute(name, data[key.alias])
          @removed_keys.delete(key.alias)
        elsif data.key? name # ...but may be stored under the full name
          initialize_attribute(name, data[name])

          # Force a re-save for this key
          #   this way we'll write the field under the alias, and remove the old
          #   key on the next save
          @new_keys << name
          @removed_keys.delete(name)
        else
          if key.default
            if key.default.respond_to?(:call) # It's a Proc - deal with it later
              post_process_defaults << name
            else
              initialize_attribute(name, key.default)
            end
          else
            initialize_attribute(name, nil)
          end

          @new_keys << name
        end
      end

      # Post-processing
      post_process_defaults.each do |name|
        initialize_attribute(name, key_objects[name].default.call(self))
      end
    end


    # Set a value for an attribute without triggering the dirty tracking. This
    # will call {Mandrake::Key#create_attribute} internally.
    #
    # @param [Symbol] name The name of the attribute
    # @param value The value to initialize with.
    #
    # @return [void]
    def initialize_attribute(name, value)
      @attribute_objects[name] = key_objects[name].create_attribute(value)
    end

    private :initialize_attribute


    # Read the value for a given attribute. Proxies to {Mandrake::Type::Base#value}.
    #
    # @todo We'll need to deal with non-existent attributes. Either quietly return nil, or raise an Exception - what do others do?
    #
    # @param [String, Symbol] name The attribute name
    # @return []
    def read_attribute(name)
      @attribute_objects[name].value
    end


    # Update given attribute with a new value.
    #
    # @param [String, Symbol] name The attribute name
    # @param [] val
    # @return [] The updated value
    def write_attribute(name, val)
      changed_attributes[name] = read_attribute(name)
      @attribute_objects[name].value = val
    end


    # If an attribute supports incrementing, this will return the amount the value
    # was incremented by.
    #
    # @param [String, Symbol] name The attribute name
    # @return [Numeric]
    def attribute_incremented_by(name)
      raise "Type #{key_objects[name].type} doesn't support incrementing" unless @attribute_objects[name].respond_to?(:incremented_by)
      @attribute_objects[name].incremented_by
    end


    # If an attribute supports incrementing, this will increment it by a given amount.
    # Proxies to the increment method on the {Mandrake::Type::Numeric} type.
    #
    # @param [String, Symbol] name The attribute name
    # @param [Numeric, NilClass] amount The amount to increment by
    def increment_attribute(name, amount = nil)
      raise "Type #{key_objects[name].type} doesn't support incrementing" unless @attribute_objects[name].respond_to?(:increment)
      changed_attributes[name] = read_attribute(name)
      @attribute_objects[name].inc(amount)
    end

    alias_method :inc, :increment_attribute


    # Proxies to the push method on the {Mandrake::Type::Collection} type.
    #
    # @param [String, Symbol] name The attribute name
    # @param value The value to add to the collection
    def push_to_attribute(name, value)
      raise "Type #{key_objects[name].type} doesn't support pushing" unless @attribute_objects[name].respond_to?(:push)
      changed_attributes[name] = read_attribute(name)
      @attribute_objects[name].push(value)
    end

    alias_method :push, :push_to_attribute


    # Proxies to the pull method on the {Mandrake::Type::Collection} type.
    #
    # @param [String, Symbol] name The attribute name
    # @param value The value to remove from the collection
    def pull_from_attribute(name, value)
      raise "Type #{key_objects[name].type} doesn't support pulling" unless @attribute_objects[name].respond_to?(:pull)
      changed_attributes[name] = read_attribute(name)
      @attribute_objects[name].pull(value)
    end

    alias_method :pull, :pull_from_attribute
  end
end