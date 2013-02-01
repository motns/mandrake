module Mandrake
  module Validator
    class Format < Base

      # Pre-defined formats that can be used in place of a Regex
      FORMATS = {
        :email => /^[\w\.\+\-]+@[\w\-]+\.([\w\-]+\.)*([A-Za-z])+$/,
        :ip => /^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$/
      }

      @error_codes = {
        :not_email =>   "has to be a valid email address",
        :not_ip =>      "has to be a valid ip address",
        :wrong_format =>  "has to be in the correct format"
      }

      protected
        def self.run_validator(value, params={})
          raise ArgumentError, "Missing :format parameter for Format validator" unless params.key? :format

          format = params[:format]

          unless format.is_a?(::Regexp) || format.is_a?(::Symbol)
            raise ArgumentError, "The :format parameter has to be either a Symbol or a Regexp, #{params[:format].class.name} given"
          end

          if format.is_a?(::Symbol)
            raise ArgumentError, %Q(Unknown format "#{format}" in Format validator) unless FORMATS.key? format
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