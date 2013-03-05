require 'time'

module Mandrake
  module Type
    # Type class based on the built-in Ruby Time class
    class Time < Base

      # Default parameters for this Type, processed by {Mandrake::Type::Base.params}.
      PARAMS = {:in => nil}


      # Sets new value:
      # - nil is preserved
      # - Time class used directly
      # - Integer and Float taken as timestamp
      # - String parsed
      # - all other values reset to nil
      #
      # @param [NilClass, Time, Integer, Float, String] val New time
      # @ return [Time, nil] The updated value
      def value=(val)
        @value = if val.nil? then nil
                 elsif val.is_a?(::Time) then val
                 elsif val.is_a?(::Integer) || val.is_a?(::Float) then ::Time.at(val)
                 elsif val.is_a?(::String) then ::Time.parse(val)
                 else nil
                 end
      end
    end
  end
end