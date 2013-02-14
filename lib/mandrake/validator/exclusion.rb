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

          raise ArgumentError, "Missing :not_in parameter for Exclusion validator" unless params.key? :not_in
          raise ArgumentError, "The :not_in parameter must be provided as an Enumerable, #{params[:not_in].class.name} given" unless params[:not_in].respond_to?(:include?)

          if params[:not_in].include? value
            if params[:not_in].is_a?(::Range)
              set_error :in_range, params[:not_in].min, params[:not_in].max
            else
              set_error :in_set, params[:not_in].to_a.join(', ')
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