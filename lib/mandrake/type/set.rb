require 'set'

module Mandrake
  module Type
    # Type class based on a Ruby Set, meaning that values are unordered, but
    # uniqueness is ensured by default. Not recommended for very large lists,
    # as it may be slow in the DB layer.
    class Set < Collection
      # Add given value(s) to set
      #
      # @param args One or more values to add
      def push(*args)
        args.each do |val|
          @removed.delete(val)
          @value ||= ::Set.new
          @value << val
          @added << val
        end
      end


      # Remove given value(s) from set
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


      # Replace this Set with a new one. Resets to nil if the new value is not
      # a Set, and can't be converted to one.
      #
      # @param [Set] val
      def value=(val)
        @added = []
        @removed = []

        @value = if val.nil? then nil
                 elsif val.is_a?(::Set) then val
                 elsif val.respond_to?(:to_set) then val.to_set
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

        return :modifier if base_value == @initial_value
        return :setter
      end
    end
  end
end