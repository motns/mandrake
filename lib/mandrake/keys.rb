module Mandrake
  module Keys
    extend ActiveSupport::Concern

    attr :new_keys, :removed_keys

    def initialize(attrs = {})
      @attributes = {}
      @changed_attributes = {}
      @previously_changed = {}


      # New fields to write on next save
      @new_keys = []
      # Fields to remove on next save
      @removed_keys = attrs.keys


      # Load data
      keys.each do |k, v|
        if attrs.key? v[:alias] # Data should be stored under the alias...
          @attributes[k] = attrs[v[:alias]]
          @removed_keys.delete(v[:alias])
        elsif attrs.key? k # ...but may be stored under the full name
          @attributes[k] = attrs[k]

          # Force a re-save for this field
          #   this way we'll write the field under the alias, and remove the old
          #   key on the next save
          @new_keys << k
          @removed_keys.delete(k)
        else
          # @TODO - proper defaults here
          #   * split by pre- and post-processing defaults (flat values vs. Procs)
          @attributes[k] = nil
          @new_keys << k
        end
      end
    end


    def keys
      self.class.keys
    end


    ########################################
    # Change tracking

    def changed?
      not @changed_attributes.empty?
    end

    def changes
      return nil if @changed_attributes.empty?

      changes = {}

      @changed_attributes.each do |key, old|
        changes[key] = [old, @attributes[key]]
      end

      changes
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

        keys[name] = {
          :type => type,
          :alias => field_alias,
          :required => opt[:required] || false,
          :default => opt[:default] || nil,
          :length => opt[:length] || nil,
          :format => opt[:format] || nil
        }

        aliases[field_alias] = name


        ##########################################################
        # Create field accessors
        # and also ActiveModel::Dirty tracking stuff

        self.class_eval do
          # Getter
          define_method name do
            @attributes[name]
          end

          alias_method field_alias, name unless name == field_alias


          # Setter
          field_setter = "#{name}=".to_sym
          setter_alias = "#{field_alias}=".to_sym

          define_method field_setter do |val|
            @changed_attributes[name] = @attributes[name]
            @attributes[name] = val
          end

          alias_method setter_alias, field_setter unless field_setter == setter_alias


          # Change reflection
          field_changed_method = "#{name}_changed?".to_sym
          field_change_method = "#{name}_change".to_sym
          field_was_method = "#{name}_was".to_sym

          define_method field_changed_method do
            @changed_attributes.key? name
          end

          # => [original, new]
          define_method field_change_method do
            if @changed_attributes.key? name
              [@changed_attributes[name], @attributes[name]]
            else
              nil
            end
          end

          define_method field_was_method do
            @changed_attributes[name]
          end
        end

      end
    end
  end
end