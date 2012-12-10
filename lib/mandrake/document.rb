module Mandrake
	module Document

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

        field_alias = opt[:as] || name

        raise %Q(Alias "#{field_alias}" already taken) if aliases.key? field_alias
        raise %Q(Alias "#{field_alias}" is already used as a field name) if keys.key? field_alias

        keys[name] = {
          :type => type,
          :alias => field_alias
        }

        aliases[field_alias] = name

      end
    end

    def self.included(mod)
      mod.extend(ClassMethods)
    end

	end
end