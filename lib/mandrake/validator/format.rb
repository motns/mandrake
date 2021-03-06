module Mandrake
  module Validator
    # Checks whether the format of a value matches a given Regex. Also has a set of
    # pre-defined formats for convenience.
    class Format < Base

      # Pre-defined formats that can be used in place of a Regex
      FORMATS = {
        :email => /^[\w\.\+\-]+@[\w\-]+\.([\w\-]+\.)*([A-Za-z])+$/,
        :ip => /^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$/,
        :alnum => /^[a-zA-Z0-9]+$/,
        :hex => /^[0-9a-fA-F]+$/
      }

      @error_codes = {
        :not_email =>    "has to be a valid email address",
        :not_ip =>       "has to be a valid ip address",
        :not_alnum =>    "can only contain letters and numbers",
        :not_hex =>      "has to be a valid hexadecimal number",
        :wrong_format => "has to be in the correct format"
      }

      protected
        # Run validation. Returns True if the given value matches the Regexp, False
        # otherwise.
        #
        # @param value
        # @param [Hash] params
        # @option params [Regexp, Symbol] :format A regular expression, or the name of a pre-defined format
        #
        # @raise [ArgumentError] If the :format parameter is not defined
        # @raise [ArgumentError] If the :format parameter is not a Regexp or Symbol
        # @raise [ArgumentError] If the :format parameter refers to an unknown format
        #
        # @return [TrueClass, FalseClass] Validation success
        def self.run_validator(value, params={})
          return true if value.nil?

          raise ArgumentError, "Missing :format parameter for Format validator" unless params.key? :format

          format = params[:format]

          unless format.is_a?(::Regexp) || format.respond_to?(:to_sym)
            raise ArgumentError, "The :format parameter has to be either a Symbol or a Regexp, #{params[:format].class.name} given"
          end

          if format.respond_to?(:to_sym)
            raise ArgumentError, %Q(Unknown format "#{format}" in Format validator) unless FORMATS.key? format.to_sym
            regex = FORMATS[format]
            code = "not_#{format}".to_sym
          else
            regex = format
            code = :wrong_format
          end


          if regex =~ value
            true
          else
            set_error code
            false
          end
        end
      # end Protected
    end
  end
end