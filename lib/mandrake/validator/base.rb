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

      # The number of values this
      def self.inputs
        @inputs ||= 1
      end

      def self.error_codes
        @error_codes
      end

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

      # Optional params is used to fill in placeholder that may be found in the text
      def self.set_error(code, *params)
        code = code.to_sym
        raise "Unknown error code #{code} for validator #{self.name}" unless @error_codes.key? code

        message = @error_codes[code]
        message = sprintf(message, *params) unless params.empty?

        @last_error = message
        @last_error_code = code
      end

      # Returns true/false
      def self.validate(*args)
        reset_last_error

        values, params = Mandrake::extract_params(*args)

        raise ArgumentError, "This validator takes #{inputs} value(s) for validation, #{args.size} given" unless values.size == inputs

        run_validator(*values, params)
      end

      def self.inherited(descendant)
        demodulized = descendant.name.to_s.gsub(/^.*::/, '')
        ::Mandrake::Type.demodulized_names[demodulized] = descendant
      end
    end
  end
end