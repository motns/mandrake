module Mandrake
  module Keys
    extend ActiveSupport::Concern


    # Shortcut for getting Model keys from intance
    def keys
      self.class.keys
    end


    module ClassMethods

      # Document schema definition: field_name => properties
      def keys
        @keys ||= {}
      end


      # Reverse lookup for matching aliases to field names: alias => field_name
      def aliases
        @aliases ||= {}
      end


      def key(name, type, opt = {})
        name = name.to_sym

        raise %Q(Key "#{name}" is already defined) if keys.key? name
        raise %Q(Key name "#{name}" is already used as an alias for another field) if aliases.key? name

        field_alias = (opt[:as] || name).to_sym

        raise %Q(Alias "#{field_alias}" already taken) if aliases.key? field_alias
        raise %Q(Alias "#{field_alias}" is already used as a field name) if keys.key? field_alias

        raise %Q(Length option for "#{name}" has to be an Integer or a Range) if opt[:length] && ! (opt[:length].is_a?(Integer) || opt[:length].is_a?(Range))
        raise %Q(Format option for "#{name}" has to be a Regexp) if opt[:format] && ! opt[:format].is_a?(Regexp)

        keys[name] = {
          :type => type,
          :alias => field_alias,
          :required => opt[:required] || false,
          :default => opt[:default] || nil,
          :length => opt[:length] || nil,
          :format => opt[:format] || nil
        }

        aliases[field_alias] = name


        create_key_accessors(name, field_alias)
        create_dirty_tracking(name, field_alias)
      end


      private
        def create_key_accessors(name, field_alias)
          model_methods_module.module_eval do
            # Getter
            define_method name do
              @attributes[name]
            end

            alias_method field_alias, name unless name == field_alias


            # Setter
            field_setter = "#{name}=".to_sym
            setter_alias = "#{field_alias}=".to_sym

            define_method field_setter do |val|
              changed_attributes[name] = @attributes[name]
              @attributes[name] = val
            end

            alias_method setter_alias, field_setter unless field_setter == setter_alias
          end
        end
      # end private
    end
  end
end