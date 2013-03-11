module Mandrake
  # Provides class methods for creating new keys in a {Mandrake::Model}
  module Keys
    extend ActiveSupport::Concern


    # Shortcut for getting the model schema from the current instance. It's just
    # a proxy for the key_objects method of the class.
    #
    # @return [Hash] A hash describing the schema
    def key_objects
      self.class.key_objects
    end


    # Methods to extend the class we're included in
    module ClassMethods

      # Returns a hash containing the {Mandrake::Key} objects under the key names
      # defined for this Model:
      #
      #    {
      #       :key_name1 => key_object1,
      #       :key_name2 => key_object2
      #    }
      #
      # @return [Hash]
      def key_objects
        @key_objects ||= {}
      end


      # Returns a Hash with the current document schema definition, in the format:
      #
      #   {
      #     :key_name => {
      #       :type => :DataType,
      #       :alias => :key_name_alias,
      #       :required => true,
      #       :default => nil,
      #       :description => ""
      #     }
      #   }
      #
      # @return [Hash]
      def schema
        {}.tap do |h|
          key_objects.each do |name, key_object|
            h[name] = {
              :type => key_object.type,
              :alias => key_object.alias,
              :required => key_object.required,
              :default => key_object.default,
              :description => key_object.description
            }

            key_object.params.each do |k, v|
              h[name][k] = v
            end
          end
        end
      end


      # Returns a Hash with a reverse lookup of aliases to key names
      #
      #   {
      #     :t => :title,
      #     :n => :name
      #   }
      #
      # @return [Hash]
      def aliases
        @aliases ||= {}
      end


      # Define a new {Mandrake::Key} in current {Mandrake::Model}
      #
      # @param (see Mandrake::Key#initialize)
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

        # @todo - implement these with an observer pattern
        create_dirty_tracking(key_objects[name])
        create_validations_for(key_objects[name])
      end


      # Create getter and setter methods for a newly defined key. Internally
      # it just proxies to {Mandrake::Model#read_attribute} and {Mandrake::Model#write_attribute}.
      #
      # @param [Mandrake::Key] key
      # @return [void]
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

      private :create_key_accessors
    end
  end
end