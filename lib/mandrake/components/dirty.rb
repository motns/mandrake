module Mandrake
  # Used to create change tracking methods for a {Mandrake::Model}
  module Dirty

    # Returns a hash with all the keys that were updated, and their old value
    # before the update
    #
    # @return [Hash]
    def changed_attributes
      @changed_attributes ||= {}
    end


    # Returns a list of keys which have been updated
    #
    # @return [Array]
    def changed
      changed_attributes.keys
    end


    # Whether or not any of the attributes have been updated
    #
    # @return [TrueClass, FalseClass]
    def changed?
      not changed_attributes.empty?
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
      return nil if changed_attributes.empty?

      {}.tap do |h|
        changed_attributes.each do |key, old|
          h[key] = [old, read_attribute(key)]
        end
      end
    end


    # Whether or not a specific attribute has been updated
    #
    # @param [Symbol] name The name of the attribute
    # @return [TrueClass, FalseClass]
    def attribute_changed?(name)
      changed_attributes.key? name
    end


    # Returns an array with the old and new values for a given attribute, or nil
    # if there is no change.
    #
    # @param [Symbol] name The name of the attribute
    # @return [Array] The change in the form of [old_value, new_value]
    def attribute_change(name)
      if changed_attributes.key? name
        [changed_attributes[name], read_attribute(name)]
      else
        nil
      end
    end


    # Returns the old value for an attribute if it was changed, or nil otherwise
    #
    # @param [Symbol] name The name of the attribute
    # @return [Class, NilClass]
    def attribute_was(name)
      changed_attributes[name]
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


    # Loads in Class Methods
    def self.included(base)
      base.extend ClassMethods
    end
  end
end