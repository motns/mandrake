module Mandrake
  module Type
    # Type class based on a standard Ruby Array, meaning that values are ordered
    # by default. This type of Collection allows duplicate values, but in turn
    # will be faster to append to in the DB layer.
    class Array < Collection
      # Add given value(s) to list
      #
      # @param args One or more values to add
      def push(*args)
        args.each do |val|
          @removed.delete(val)
          @value ||= []
          @value << val
          @added << val
        end
      end


      # Remove given value(s) from list
      #
      # @param args One or more values to remove
      def pull(*args)
        args.each do |val|
          @added.delete(val)

          # @removed is only for items which we'll remove when the Model is
          # persisted
          unless @initial_value.nil?
            @removed << val if @initial_value.include?(val)
          end

          unless @value.nil?
            @value.delete(val)
          end
        end
      end


      # Replace this array with a new one. Resets to nil if the new value is not
      # an Array, and can't be converted to one.
      #
      # @param [Array] val
      def value=(val)
        @added = []
        @removed = []

        @value = if val.nil? then nil
                 elsif val.is_a?(::Array) then val
                 elsif val.respond_to?(:to_a) then val.to_a
                 else nil
                 end
      end


      # Determine whether the value was modified by the setter, or one of the modifiers
      #
      # @return (see Mandrake::Type::Base#changed_by)
      def changed_by
        return :setter if @initial_value.nil? || @value.nil? || @value == @initial_value

        # the value was clearly altered, now let's see how

        base_value = @value.clone
        base_value -= @added
        base_value += @removed

        # Bit of a hack for comparing two arrays without order
        return :modifier if (base_value - @initial_value).empty? && (@initial_value - base_value).empty?
        return :setter
      end
    end
  end
end