module Mandrake
  class EmbeddedModel
    attr :model

    def initialize(klass, data = nil)
      @klass = klass
      @model = if data.nil? then nil
               else klass.new(data)
               end
    end

    def model=(val);
      @model = if val.is_a?(@klass) then val
               else
                 # @todo Put a warning in the logs
                 nil
               end
    end
  end
end