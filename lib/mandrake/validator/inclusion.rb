module Mandrake
  module Validator
    class Inclusion < Base

      @error_codes = {
        :not_in_range => "must be between %s and %s",
        :not_in_set => "must be one of: %s"
      }

      protected
        def self.run_validator(value, params={})
          return true if value.nil?

          raise ArgumentError, "Missing :in parameter for Inclusion validator" unless params.key? :in
          raise ArgumentError, "The :in parameter must be provided as an Enumerable, #{params[:in].class.name} given" unless params[:in].respond_to?(:include?)

          if params[:in].include? value
            true
          else
            if params[:in].is_a?(::Range)
              set_error :not_in_range, params[:in].min, params[:in].max
            else
              set_error :not_in_set, params[:in].to_a.join(', ')
            end

            false
          end
        end
      # end Protected
    end
  end
end