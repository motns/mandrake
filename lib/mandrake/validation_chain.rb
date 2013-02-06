module Mandrake
  class ValidationChain

    attr :stop_on_failure, :items

    def initialize(stop_on_failure = true)
      @stop_on_failure = stop_on_failure
      @items = []
    end


    def add(*items)
      items.each do |item|
        unless item.is_a?(::Mandrake::Validation) || item.is_a?(::Mandrake::ValidationChain)
          raise ArgumentError, "Validator chain item has to be a Validator or another ValidationChain"
        end

        @items << item
      end
    end


    def run(document)
      success = true

      @items.each do |item|
        validation_success = item.run(document)
        success = success && validation_success
        break if @stop_on_failure && ! success
      end

      success
    end
  end
end