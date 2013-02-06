module Mandrake
  module Type
    def self.type_registry
      @type_registry ||= {}
    end

    def self.get_class(type)
      return Type.type_registry[type.to_sym] if type.respond_to?(:to_sym)
      return nil
    end

  	class Base
      def initialize(val)
        self.send :value=, val
      end

      def self.inherited(descendant)
        id = descendant.name.to_s.gsub(/^.*::/, '').to_sym
        ::Mandrake::Type.type_registry[id] = descendant
      end

      # Sub-classes should override this, and do proper type-casting
      def value=(val)
        @value = val
      end

      def value
        @value
      end


      # name => default_value
      def self.params
        # This crazy workaround is required for summing up a set of parameters
        # from all sub-classes
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