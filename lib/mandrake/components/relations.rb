module Mandrake
  # Used to establish a link to other {Mandrake::Model} classes. You can either
  # embed another Model (or list of Models), or create an external reference.
  module Relations
    extend ActiveSupport::Concern


    # Shortcut for getting the relationships defined for this class from an instance
    #
    # @return [Hash]
    def relations
      self.class.relations
    end


    # Methods to extend the class we're included in
    module ClassMethods
      # Returns a hash with all the currently defined relationships:
      #
      #     {
      #       :embed_one => {
      #         :ModelName => {
      #           :model => ModelClass,
      #           :alias => key_alias
      #         }
      #       }
      #     }
      #
      # @return [Hash]
      def relations
        @relations ||= {}
      end


      # Merge our relation schemas into the key schemas
      #
      # @see Mandrake::Keys#schema
      def schema
        super.merge(relations_schema)
      end


      # Returns a hash with the schema for any embedded documents or document lists
      #
      # @return [Hash]
      def relations_schema
        {}.tap do |h|
            relations[:embed_many].each do |name, relation|
                :alias => relation[:alias],
              }
          {
            :embed_many => :embedded_model_list
          }.each do |key, type|

            if relations[key]
              relations[key].each do |name, relation|
                h[name] = {
                  :type => type,
                  :alias => relation[:alias],
                  :schema => relation[:model].schema
                }
              end
            end
          end
        end
      end


      # Add our relation aliases to key aliases
      #
      # @see Mandrake::Keys#aliases
      def aliases
        super.merge(relation_aliases)
      end


      # Returns a hash with aliases for embedded documents and document lists
      #
      # @return [Hash]
      def relation_aliases
        {}.tap do |h|
          relations.each do |type, relationships|
            relationships.each do |name, relationship|
              h[relationship[:alias]] = name
            end
          end
        end
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

        validate_model(model)

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

        create_key_accessors(name, key_alias)
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

        validate_model(model)

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

        create_key_accessors(name, key_alias)
      end


      # Check if the argument provided is a {Mandrake::Model} class, or a sub-class of it
      #
      # @raise Mandrake::Error::EmbedError
      #
      # @param [Class] model
      # @retun [TrueClass]
      def validate_model(model)
        raise Mandrake::Error::EmbedError, "model has to be a Mandrake::Model class, #{model.name} given" unless ! model.nil? && model <= Mandrake::Model
      end
    end
  end
end