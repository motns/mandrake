module Mandrake
  module Type
    # Type class for storing textual values. Lenght is restricted to 50 characters
    # by default, but this can be overridden. There are no default restrictions
    # on format.
  	class ObjectId < Base

      # Sets new value. BSON::ObjectId and nil are taken as-is, while String values
      # are converted to BSON::ObjectId, but only if they are in the right format.
      #
      # @param val New value
      # @ return [String, nil] The updated value
      def value=(val)
        @value = if val.nil? then nil
                 elsif val.is_a?(BSON::ObjectId) then val
                 elsif BSON::ObjectId.legal?(val) then BSON::ObjectId.from_string(val)
                 else
                  # @todo Raise error in logs
                  nil
                 end
      end
    end
	end
end