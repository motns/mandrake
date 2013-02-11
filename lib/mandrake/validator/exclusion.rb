module Mandrake
  module Validator
    class Exclusion < Base

      @error_codes = {
        :in_range => "must not be between %s and %s",
        :in_set => "must not be any of: %s"
      }

      protected
        def self.run_validator(value, params={})
          return true if value.nil?

          raise ArgumentError, "Missing :in parameter for Exclusion validator" unless params.key? :in
          raise ArgumentError, "The :in parameter must be provided as an Enumerable, #{params[:in].class.name} given" unless params[:in].respond_to?(:include?)

          if params[:in].include? value
            if params[:in].is_a?(::Range)
              set_error :in_range, params[:in].min, params[:in].max
            else
              set_error :in_set, params[:in].to_a.join(', ')
            end

            false
          else
            true
          end
        end
      # end Protected
    end
  end
end