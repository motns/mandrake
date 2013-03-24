module Mandrake
  # A wrapper used to represent a list of embedded Models within another Model instance
  class EmbeddedModelList
    include Enumerable

    # @param [Class] klass The {Mandrake::Model} class we're embedding
    # @param [Array<Hash>] data_list The list of data hashes to initialize the embedded Model with
    def initialize(klass, data_list = [])
      @klass = klass
      build(data_list)
    end


    # Initialize the embedded Model instances with given data. Can be used to replace
    # the current embedded Model list with a new one, built from scratch.
    #
    # @param [Array<Hash>] data_list
    def build(data_list)
      @models = []

      data_list.each do |data|
        @models << @klass.new(data)
      end
    end


    # Replace the current embedded Model list with a new one. If any of the new instance
    # provided are of the wrong type, they will be skipped, and a warning will be logged.
    #
    # @param [Array<Mandrake::Model>, Array, NilClass]
    def models=(data_list)
      @models = []

      unless data_list.nil? || data_list.empty?
        data_list.each do |data|
          @models << data if data.is_a?(@klass)
          # @todo Put error in logs on invalid types
        end
      end
    end


    # Create a new instance of the embedded @klass, and add it to the list
    #
    # @param [Hash] data The data to initialize the Model with
    def new(data)
      push @klass.new(data)
    end


    # Add a new instance of the embedded @klass to the list, but only if it's the
    # correct type. Raises a warning otherwise.
    #
    # @param [Mandrake::Model] model
    def <<(model)
      if model.is_a?(@klass)
        @models << model
      else
        # @todo Write a warning into the logs
      end
    end
    alias_method :push, :<<


    # Return embedded model instance at given index
    #
    # @param [Fixnum] index
    # @return [Mandrake::Model]
    def [](index); @models[index]; end


    # Replace embedded model instace at given index with a new one
    #
    # @param [Fixnum] index
    # @param [Mandrake::Model] value
    def []=(index, value)
      if value.is_a?(@klass)
        @models[index] = value
      else
        # @todo Write a warning into the logs
      end
    end


    # For supporting the Enumerable module
    def each(&block)
      @models.each {|model| block.call(model)}
    end
  end
end