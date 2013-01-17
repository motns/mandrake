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
        @value = val
      end

      def self.inherited(descendant)
        demodulized = descendant.name.to_s.gsub(/^.*::/, '')
        ::Mandrake::Type.demodulized_names[demodulized] = descendant
      end

      def value=(val)
        @value = val
      end

      def value
        @value
      end

      def self.param(hash)
        hash.each do |k, v|
          params[k] = v
        end
      end

      # name => default_value
      def self.params
        @params ||= {}
      end

    end
  end
end