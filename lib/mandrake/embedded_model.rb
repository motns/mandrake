module Mandrake
  # A wrapper used to represent a single embedded Model within another Model instance
  class EmbeddedModel
    attr :model

    # @param [Class] klass The {Mandrake::Model} class we're embedding
    # @param [Hash, NilClass] data The data to initialize the embedded Model with
    def initialize(klass, data = nil)
      @klass = klass
      build(data)
    end


    # Initialize the embedded Model instance with given data. Can be used to replace
    # the current embedded Model instance with a new one, built from scratch.
    #
    # @param [Hash, NilClass] data
    def build(data)
      @model = if data.nil? then nil
               else @klass.new(data)
               end
    end


    # Replace the current embedded Model instance with a new one. If the new instance
    # provided is of the wrong type, the value is reset to nil, and a warning is logged.
    #
    # @param [Mandrake::Model]
    def model=(val)
      @model = if val.is_a?(@klass) then val
               else
                 # @todo Put a warning in the logs
                 nil
               end
    end
  end
end