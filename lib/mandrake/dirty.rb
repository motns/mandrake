module Mandrake
  module Dirty
    extend ActiveSupport::Concern


    ######################################
    # Change-tracking attributes

    def changed_attributes
      @changed_attributes ||= {}
    end

    def previously_changed
      @previously_changed ||= {}
    end


    #####################################
    # Document-wide changes

    def changed
      changed_attributes.keys
    end

    def changed?
      not changed_attributes.empty?
    end

    def changes
      return nil if changed_attributes.empty?

      changes = {}

      changed_attributes.each do |key, old|
        changes[key] = [old, @attributes[key]]
      end

      changes
    end


    #####################################
    # Field-specific changes

    def attribute_changed?(name)
      changed_attributes.key? name
    end

    def attribute_change(name)
      if changed_attributes.key? name
        [changed_attributes[name], @attributes[name]]
      else
        nil
      end
    end

    def attribute_was(name)
      changed_attributes[name]
    end


    #####################################
    # Field-specific change shortcuts

    module ClassMethods
      def create_dirty_tracking(name, field_alias)
        field_changed_method = "#{name}_changed?".to_sym
        field_change_method = "#{name}_change".to_sym
        field_was_method = "#{name}_was".to_sym

        model_methods_module.module_eval do
          define_method field_changed_method do
            attribute_changed? name
          end

          # => [original, new]
          define_method field_change_method do
            attribute_change(name)
          end

          define_method field_was_method do
            attribute_was(name)
          end
        end
      end
    end
  end
end