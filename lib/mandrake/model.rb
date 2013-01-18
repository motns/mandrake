module Mandrake
  module Model
    extend ActiveSupport::Concern

    COMPONENTS = [
      Mandrake::Keys,
      Mandrake::Dirty,
      Mandrake::Validations
    ]


    included do |base|
      COMPONENTS.each do |component|
        base.send :include, component
      end
    end


    module ClassMethods
      def model_methods_module
        @model_methods_module ||= begin
          mod = Module.new
          include(mod)
          mod
        end
      end
    end


    attr :new_keys, :removed_keys

    def initialize(attrs = {})
      @attribute_objects = {}

      # New fields to write on next save
      @new_keys = []
      # Fields to remove on next save
      @removed_keys = attrs.keys


      # List of keys with defaults to process after
      # the rest of the data has been loaded
      post_process_defaults = []


      # Load data
      key_objects.each do |name, key|
        if attrs.key? key.alias # Data should be stored under the alias...
          initialize_attribute(name, attrs[key.alias])
          @removed_keys.delete(key.alias)
        elsif attrs.key? name # ...but may be stored under the full name
          initialize_attribute(name, attrs[name])

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

    # Set a value for an attribute without triggering the dirty tracking
    def initialize_attribute(name, value)
      @attribute_objects[name] = key_objects[name].create_attribute(value)
    end

    private :initialize_attribute


    ############################################################################

    def read_attribute(name)
      @attribute_objects[name].value
    end

    def write_attribute(name, val)
      changed_attributes[name] = read_attribute(name)
      @attribute_objects[name].value = val
    end

    def increment_attribute(name, amount = nil)
      changed_attributes[name] = read_attribute(name)
      @attribute_objects[name].inc(amount)
    end
  end
end