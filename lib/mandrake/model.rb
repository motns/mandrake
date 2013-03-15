module Mandrake
  # Used to augment an arbitrary class with methods for defining a data schema,
  # with relevant validations for that schema. These classes can then be instantiated
  # to store data in the given format.
  #
  # @note Model classes have no persistence built into them.
  #   Persistence into a data store is handled by separate classes wrapping a Model.
  #
  # @!attribute [r] force_save_keys
  #   @return [Array<Symbol>] A list of keys that will be written on the next save,
  #       irrespective of their dirty? value
  #
  module Model
    extend ActiveSupport::Concern

    attr :force_save_keys


    # Additional modules to load in
    COMPONENTS = [
      Mandrake::Callbacks,
      Mandrake::Keys,
      Mandrake::Dirty,
      Mandrake::Validations,
      Mandrake::Relations
    ]


    included do |base|
      COMPONENTS.each do |component|
        base.send :include, component
      end

      base.extend ActiveModel::Naming
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
      run_callbacks :initialize do
        @attribute_objects = {}
        aliases = self.class.aliases
        @force_save_keys = aliases.values_at(*(aliases.keys - data.keys)).compact

        build_keys(data)
      end
    end


    # Set the initial values for key attributes within this Model instance,
    # using data provided in a Hash.
    #
    # @note This does not handle embedded documents
    # @param [Hash] data
    # @return [void]
    def build_keys(data)
      # List of keys with defaults to process after the rest of the
      # data has been loaded
      post_process_keys = []

      key_objects.each do |name, key|
        if data.key? key.alias # Data should be stored under the alias...
          @attribute_objects[name] = key.create_attribute(data[key.alias])
        elsif data.key? name # ...but may be stored under the full name
          @attribute_objects[name] = key.create_attribute(data[name])
        else # new key - set to default
          if key.default.respond_to?(:call) # It's a Proc - deal with it later
            post_process_keys << name
          else
            @attribute_objects[name] = key.create_attribute(key.default)
          end
        end
      end

      post_process_keys.each do |name|
        key = key_objects[name]
        @attribute_objects[name] = key.create_attribute(key.default.call(self))
      end
    end

    private :build_keys


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
      run_callbacks :attribute_change do
        @attribute_objects[name].value = val
      end
    end


    # Proxies to {Mandrake::Type::Base#changed_by} to check how the attribute was modified
    #
    # @param [String, Symbol] name The attribute name
    # @return [Symbol]
    def attribute_changed_by(name)
      @attribute_objects[name].changed_by
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
      run_callbacks :attribute_change do
        raise "Type #{key_objects[name].type} doesn't support incrementing" unless @attribute_objects[name].respond_to?(:increment)
        @attribute_objects[name].inc(amount)
      end
    end

    alias_method :inc, :increment_attribute


    # Proxies to the push method on the {Mandrake::Type::Collection} type.
    #
    # @param [String, Symbol] name The attribute name
    # @param value The value to add to the collection
    def push_to_attribute(name, value)
      run_callbacks :attribute_change do
        raise "Type #{key_objects[name].type} doesn't support pushing" unless @attribute_objects[name].respond_to?(:push)
        @attribute_objects[name].push(value)
      end
    end

    alias_method :push, :push_to_attribute


    # Proxies to the pull method on the {Mandrake::Type::Collection} type.
    #
    # @param [String, Symbol] name The attribute name
    # @param value The value to remove from the collection
    def pull_from_attribute(name, value)
      run_callbacks :attribute_change do
        raise "Type #{key_objects[name].type} doesn't support pulling" unless @attribute_objects[name].respond_to?(:pull)
        @attribute_objects[name].pull(value)
      end
    end

    alias_method :pull, :pull_from_attribute
  end
end