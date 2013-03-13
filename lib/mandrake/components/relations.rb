module Mandrake
  # Used to establish a link to other {Mandrake::Model} classes. You can either
  # embed another Model (or list of Models), or create an external reference.
  module Relations
    extend ActiveSupport::Concern

    # Methods to extend the class we're included in
    module ClassMethods
      # Returns a hash with all the currently defined relationships:
      #
      #     {
      #        :embed_one => {
      #           :model => ModelClass,
      #           :alias => key_alias
      #        }
      #     }
      #
      # @return [Hash]
      def relations
        @relations ||= {}
      end


      # Embed a single instance of another {Mandrake::Model} under a given key name
      #
      # @param [Mandrake::Model] model The Model class to embed
      # @param [Symbol] name The key name to embed under - defaults to the Model name
      # @param [Hash] opt Additional options
      # @option opt [Symbol] as The alias to store the key under - defaults to the key name
      # @return [void]
      def embed_one(model, name = nil, opt = {})
        relations[:embed_one] ||= {}

        raise ArgumentError, "model has to be a Mandrake::Model class" unless ! model.nil? && model <= Mandrake::Model

        name ||= model.model_name
        name = name.to_sym
        check_key_name_uniqueness(name)
        reserved_key_names << name

        key_alias = (opt[:as] || name).to_sym

        unless key_alias == name
          check_key_name_uniqueness(key_alias)
          reserved_key_names << key_alias
        end

        relations[:embed_one][name] = {
          :model => model,
          :alias => key_alias
        }
      end


      # Embed a list of {Mandrake::Model} instances under a given key name
      #
      # @param [Mandrake::Model] model The Model class to embed
      # @param [Symbol] name The key name to embed under - defaults to the pluralised Model name
      # @param [Hash] opt Additional options
      # @option opt [Symbol] as The alias to store the key under - defaults to the key name
      # @return [void]
      def embed_many(model, name = nil, opt = {})
        relations[:embed_many] ||= {}

        raise ArgumentError, "model has to be a Mandrake::Model class" unless ! model.nil? && model <= Mandrake::Model

        name ||= model.model_name.pluralize
        name = name.to_sym
        check_key_name_uniqueness(name)
        reserved_key_names << name

        key_alias = (opt[:as] || name).to_sym

        unless key_alias == name
          check_key_name_uniqueness(key_alias)
          reserved_key_names << key_alias
        end

        relations[:embed_many][name] = {
          :model => model,
          :alias => key_alias
        }
      end
    end
  end
end