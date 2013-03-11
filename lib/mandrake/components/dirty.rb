module Mandrake
  # Used to create change tracking methods for a {Mandrake::Model}
  module Dirty
    extend ActiveSupport::Concern

    # Returns a list of keys which have been updated
    #
    # @return [Array]
    def changed
      [].tap do |a|
        @attribute_objects.each do |key, attribute|
          a << key if attribute.changed?
        end
      end
    end


    # Whether or not any of the attributes have been updated
    #
    # @return [TrueClass, FalseClass]
    def changed?
      changed = false

      @attribute_objects.each do |key, attribute|
        if attribute.changed?
          changed = true
          break
        end
      end

      changed
    end


    # Returns a hash with all the keys that were updated, and an array with the
    # old and new values for each. Format:
    #
    #   {
    #     :key_name => [old_value, new_value]
    #   }
    #
    # @return [Hash, NilClass] Returns nil if there are no changes
    def changes
      changes = {}

      @attribute_objects.each do |key, attribute|
        if attribute.changed?
          changes[key] = attribute.change
        end
      end

      return nil if changes.empty?
      changes
    end


    # Whether or not a specific attribute has been updated
    #
    # @param [Symbol] name The name of the attribute
    # @return [TrueClass, FalseClass]
    def attribute_changed?(name)
      @attribute_objects[name.to_sym].changed?
    end


    # Returns an array with the old and new values for a given attribute, or nil
    # if there is no change.
    #
    # @param [Symbol] name The name of the attribute
    # @return [Array] The change in the form of [old_value, new_value]
    def attribute_change(name)
      @attribute_objects[name.to_sym].change
    end


    # Returns the old value for an attribute if it was changed, or nil otherwise
    #
    # @param [Symbol] name The name of the attribute
    # @return [Class, NilClass]
    def attribute_was(name)
      @attribute_objects[name.to_sym].was
    end


    # Methods to extend the class we're included in
    module ClassMethods
      # Creates shortcut methods for the updated status of a specific key
      #
      # @param [Symbol] key The key name
      def create_dirty_tracking(key)
        field_changed_method = "#{key.name}_changed?".to_sym
        field_change_method = "#{key.name}_change".to_sym
        field_was_method = "#{key.name}_was".to_sym

        model_methods_module.module_eval do
          define_method field_changed_method do
            attribute_changed? key.name
          end

          # => [original, new]
          define_method field_change_method do
            attribute_change(key.name)
          end

          define_method field_was_method do
            attribute_was(key.name)
          end
        end
      end
    end
  end
end