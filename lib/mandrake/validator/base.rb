module Mandrake
  module Validator
    def self.demodulized_names
      @demodulized_names ||= {}
    end

    def self.get_class(klass)
      return klass if klass < ::Mandrake::Validator::Base
      return Type.demodulized_names[klass.to_s] if Type.demodulized_names.key?(klass.to_s)
      return nil
    end

    class Base

      @error_codes = {}

      def self.last_error
        @last_error ||= nil
      end

      def self.last_error_code
        @last_error_code ||= nil
      end

      def self.reset_last_error
        @last_error = nil
        @last_error_code = nil
      end

      def self.set_error(code)
        code = code.to_sym
        raise "Unknown error code #{code} for validator #{self.name}" unless @error_codes.key? code
        @last_error = @error_codes[code]
        @last_error_code = code
      end

      # Returns true/false
      # Resets last_error on start, sets new value on failure
      def self.validate(value, params={})
        raise "You need to define ::validate in the extending class"
      end

      def self.error_codes
        @error_codes
      end

      def self.inherited(descendant)
        demodulized = descendant.name.to_s.gsub(/^.*::/, '')
        ::Mandrake::Type.demodulized_names[demodulized] = descendant
      end
    end
  end
end