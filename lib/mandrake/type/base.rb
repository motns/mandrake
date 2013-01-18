module Mandrake
  module Type
    def self.demodulized_names
      @demodulized_names ||= {}
    end

    def self.get_class(klass)
      return klass if klass < ::Mandrake::Type::Base
      return Type.demodulized_names[klass.to_s] if Type.demodulized_names.key?(klass.to_s)
      return nil
    end

  	class Base
      def initialize(val)
        self.send :value=, val
      end

      def self.inherited(descendant)
        demodulized = descendant.name.to_s.gsub(/^.*::/, '')
        ::Mandrake::Type.demodulized_names[demodulized] = descendant
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