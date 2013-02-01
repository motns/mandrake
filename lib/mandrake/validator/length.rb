module Mandrake
  module Validator
    class Length < Base

      @error_codes = {
        :short => "has to be longer than %d characters",
        :long => "has to be shorter than %d characters"
      }

      protected
        def self.run_validator(value, params={})
          raise ArgumentError, "Missing :legth parameter for Length validator" unless params.key? :length
          raise ArgumentError, "The :length parameter has to be provided as a Range, #{params[:length].class.name} given" unless params[:length].is_a?(::Range)

          min_length = params[:length].min
          max_length = params[:length].max

          if value.respond_to? :length
            if value.length < min_length
              set_error :short, min_length
              false
            elsif value.length > max_length
              set_error :long, max_length
              false
            else
              true
            end
          else
            true
          end
        end
      # end Protected
    end
  end
end