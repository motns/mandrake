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
      @attributes = {}

      # New fields to write on next save
      @new_keys = []
      # Fields to remove on next save
      @removed_keys = attrs.keys


      # List of keys with defaults to process after
      # the rest of the data has been loaded
      post_process_defaults = []


      # Load data
      key_objects.each do |k, key_object|
        if attrs.key? key_object.alias # Data should be stored under the alias...
          @attributes[k] = attrs[key_object.alias]
          @removed_keys.delete(key_object.alias)
        elsif attrs.key? k # ...but may be stored under the full name
          @attributes[k] = attrs[k]

          # Force a re-save for this field
          #   this way we'll write the field under the alias, and remove the old
          #   key on the next save
          @new_keys << k
          @removed_keys.delete(k)
        else
          if key_object.default
            if key_object.default.respond_to?(:call) # It's a Proc - deal with it later
              post_process_defaults << k
            else
              @attributes[k] = key_object.default
            end
          else
            @attributes[k] = nil
          end

          @new_keys << k
        end
      end

      # Post-processing
      post_process_defaults.each do |k|
        @attributes[k] = key_objects[k].default.call(self)
      end
    end
  end
end