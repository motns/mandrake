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
        {}.tap do |h|
          key_objects.each do |name, key_object|
            h[key_object.alias] = name
          end

          relations.each do |type, relationships|
            relationships.each do |name, relationship|
              h[relationship.alias] = name
            end
          end
        end
      end


      # A list of symbols that can't used to name new keys or relationships. When
      # a name is used up, it's appended to this list.
      #
      # @return [Array<Symbol>]
      def reserved_key_names
        @reserved_key_names ||= []
      end


      # Check whether a given name is already used as a name or alias for another
      # key in this Model
      #
      # @raise [KeyNameError] If the name is already taken
      # @return [TrueClass]
      def check_key_name_uniqueness(name)
        raise Mandrake::Error::KeyNameError, %Q("#{name}" is already used as a name or alias for another key) if reserved_key_names.include? name
        return true
      end


      # Define a new {Mandrake::Key} in current {Mandrake::Model}
      #
      # @param (see Mandrake::Key#initialize)
      def key(name, type, opt = {})
        name = name.to_sym
        check_key_name_uniqueness(name)
        reserved_key_names << name

        key_alias = (opt[:as] || name).to_sym

        unless name == key_alias
          check_key_name_uniqueness(key_alias)
          reserved_key_names << key_alias
        end

        key_objects[name] = Mandrake::Key.new(name, type, opt)

        create_key_accessors(key_objects[name])
        create_dirty_tracking(key_objects[name])
        create_validations_for(key_objects[name])
      end


      private

        # Create getter and setter methods for a newly defined key.
        #
        # @param [Mandrake::Key] key
        # @return [void]
        def create_key_accessors(key)
          create_key_getters(key)
          create_key_setters(key)
        end


        # Create getter methods for a newly defined key. Internally it just proxies
        # to {Mandrake::Model#read_attribute}
        #
        # @param [Mandrake::Key] key
        # @return [void]
        def create_key_getters(key)
          key_name = key.name
          key_alias = key.alias

          model_methods_module.module_eval do
            define_method key_name do
              read_attribute(key_name)
            end

            alias_method key_alias, key_name unless key_name == key_alias
          end
        end


        # Create setter methods for a newly defined key. Internally it just proxies
        # to {Mandrake::Model#write_attribute}
        #
        # @param [Mandrake::Key] key
        # @return [void]
        def create_key_setters(key)
          model_methods_module.module_eval do
            field_setter = "#{key.name}=".to_sym
            setter_alias = "#{key.alias}=".to_sym

            define_method field_setter do |val|
              write_attribute(key.name, val)
            end

            alias_method setter_alias, field_setter unless field_setter == setter_alias
          end
        end

      # end private
    end
  end
end