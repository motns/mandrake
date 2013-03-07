module Mandrake
  # Used to represent the various data types that can be used in {Mandrake::Key} objects
  # and attributes in Models. They perform the appropriate type casting where necessary.
  #
  # Types may also have a default set of parameters assigned to them (via PARAMS), used when
  # creating a {Mandrake::Validation} for a given Model. For example, a String type has a default
  # length range (0 to 50 as of this writing). Any parameters which are not listed
  # in the Type Class definition will be ignored when a key with this Type is created.
  #
  # When initialized, Types become attribute objects, which will be used to hold
  # the values for keys in a {Mandrake::Model} instance.
  #
  # @!attribute [r] initial_value
  #    @return The value this Type was initialized with
  #
  # @!attribute [r] type_cast
  #    @return [TrueClass, FalseClass] Whether type casting was performed on the initial value
  module Type

    attr :initial_value, :type_cast

    # Returns a hash that maps Type names (Symbols) to the actual Type classes
    #
    # @return [Hash]
    def self.type_registry
      @type_registry ||= {}
    end


    # Returns the Type class for the given type identifier
    #
    # @param [Symbol] type The name of the Type
    #
    # @return [Class, nil] Returns the Type class if found, nil otherwise
    def self.get_class(type)
      return Type.type_registry[type.to_sym] if type.respond_to?(:to_sym)
      return nil
    end


    # The class that every Type inherits from. Its main purpose is to create a registry
    # of Type classes, so we can use short names (Symbols) when referencing them.
    #
    # It also contains a set of base methods for initializing, reading and writing
    # the Type instance values, most of which should be overridden by the extending
    # Type classes.
  	class Base
      # @param val The initial value to set
      # @return [Mandrake::Type::Base] The Type instance
      def initialize(val)
        initial = self.send(:value=, val)

        @type_cast = (serialize != val)

        # It seems there isn't a nice way to detect if an object is cloneable...
        begin
          @initial_value = initial.clone
        rescue
          @initial_value = initial
        end
      end


      # Used to add Type classes to the central registry
      #
      # @param [Class] descendant
      def self.inherited(descendant)
        id = descendant.name.to_s.gsub(/^.*::/, '').to_sym
        ::Mandrake::Type.type_registry[id] = descendant
      end


      # Default setter method. Sub-classes should override this to do proper
      # type-casting.
      #
      # @param val The value to set
      # @return The value that was just set
      def value=(val)
        @value = val
      end


      # Default getter method. Sub-classes may or may not override this.
      #
      # @return The current value for this attribute object
      def value
        @value
      end


      # Indicates how the value for this Type was changed. The default is :setter,
      # indicating that the value was changed via {Mandrake::Type::Base#value=}.
      # Sub-classes supporting atomic modifiers can override this to include :modifier.
      #
      # This method will mostly be used by the persistence adapters, when generating
      # the instructions for updating data.
      #
      # @return [Symbol]
      def changed_by; :setter end


      # Returns a serialised version of the value, to be stored in a database.
      # By default it just returns the @value, relying on the DB adapter class to
      # do the right thing. May be overridden in sub-classes for special types.
      #
      # @return The serialised value
      def serialize; @value; end


      # Whether or not this attribute object was updated
      #
      # @return [TrueClass, FalseClass]
      def changed?
        @type_cast || (@initial_value != @value)
      end


      # Returns [old_value, new_value] for this attribute, or nil if there was no change.
      #
      # @return [NilClass, Array]
      def change
        return nil unless changed?
        [@initial_value, @value]
      end


      # Returns the old value this attribute if it was changed, nil otherwise
      #
      # @return [Class, NilClass]
      def was
        return nil unless changed?
        @initial_value
      end


      # Used for collecting and merging default parameters from all the sub-classes
      #
      # @return [Hash]
      def self.params
        # This is a crazy workaround, but I can't think of a nicer way...
        # We just look for the PARAMS constant in the current class, and all
        # ancestors until we reach the root class (Base)
        {}.tap do |hash|
          self.ancestors.each do |klass| # this also includes self
            if defined?(klass::PARAMS)
              # Keep settings from sub-class
              hash.merge!(klass::PARAMS) {|key, old, new| old}
            end

            break if klass.is_a? Mandrake::Type::Base # Reached the root
          end
        end
      end

    end
  end
end