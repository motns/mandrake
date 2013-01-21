module Mandrake
  module Keys
    extend ActiveSupport::Concern

    # Shortcut for getting schema for current model
    def key_objects
      self.class.key_objects
    end


    module ClassMethods

      def key_objects
        @key_objects ||= {}
      end


      # Document schema definition: field_name => properties
      def schema
        {}.tap do |h|
          key_objects.each do |name, key_object|
            h[name] = {
              :type => key_object.type,
              :alias => key_object.alias,
              :required => key_object.required,
              :default => key_object.default
            }

            key_object.params.each do |k, v|
              h[name][k] = v
            end
          end
        end
      end


      # Reverse lookup for matching aliases to field names: alias => field_name
      def aliases
        @aliases ||= {}
      end


      # Define new key with :name, :type and additional settings in :opt
      def key(name, type, opt = {})
        name = name.to_sym

        raise %Q(Key "#{name}" is already defined) if key_objects.key? name
        raise %Q(Key name "#{name}" is already used as an alias for another field) if aliases.key? name

        field_alias = (opt[:as] || name).to_sym

        raise %Q(Alias "#{field_alias}" already taken) if aliases.key? field_alias
        raise %Q(Alias "#{field_alias}" is already used as a field name) if key_objects.key? field_alias

        key_objects[name] = Mandrake::Key.new(name, type, opt)

        aliases[field_alias] = name

        create_key_accessors(key_objects[name])
        create_dirty_tracking(key_objects[name])
        create_validations(key_objects[name])
      end


      def create_key_accessors(key)
        model_methods_module.module_eval do
          # Getter
          define_method key.name do
            read_attribute(key.name)
          end

          alias_method key.alias, key.name unless key.name == key.alias


          # Setter
          field_setter = "#{key.name}=".to_sym
          setter_alias = "#{key.alias}=".to_sym

          define_method field_setter do |val|
            write_attribute(key.name, val)
          end

          alias_method setter_alias, field_setter unless field_setter == setter_alias
        end
      end

    end
  end
end