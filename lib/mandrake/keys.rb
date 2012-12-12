module Mandrake
  module Keys
    extend ActiveSupport::Concern

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

        keys[name] = {
          :type => type,
          :alias => field_alias,
          :required => opt[:required] || false,
          :default => opt[:default] || nil,
          :length => opt[:length] || nil,
          :format => opt[:format] || nil
        }

        aliases[field_alias] = name

      end
    end
  end
end