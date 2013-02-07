module Mandrake
  class ValidationChain

    attr :stop_on_failure, :items, :prevalidations

    def initialize(stop_on_failure = true, conditions = {})
      @stop_on_failure = stop_on_failure

      # @TODO - "prevalidations" still sucks, need a better name!
      @prevalidations = []
      generate_prevalidations(conditions)

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
      return true unless conditions_met?(document)

      success = true

      @items.each do |item|
        validation_success = item.run(document)
        success = success && validation_success
        break if @stop_on_failure && ! success
      end

      success
    end


    def generate_prevalidations(conditions)
      if conditions.key? :if_present
        if conditions[:if_present].respond_to?(:to_sym) # single field
          @prevalidations << {
            :validator => ::Mandrake::Validator::Presence,
            :attribute => conditions[:if_present]
          }
        elsif conditions[:if_present].is_a?(Array)
          conditions[:if_present].each do |attribute|
            @prevalidations << {
              :validator => ::Mandrake::Validator::Presence,
              :attribute => attribute
            }
          end
        end
      end

      if conditions.key? :if_absent
        if conditions[:if_absent].respond_to?(:to_sym) # single field
          @prevalidations << {
            :validator => ::Mandrake::Validator::Absence,
            :attribute => conditions[:if_absent]
          }
        elsif conditions[:if_absent].is_a?(Array)
          conditions[:if_absent].each do |attribute|
            @prevalidations << {
              :validator => ::Mandrake::Validator::Absence,
              :attribute => attribute
            }
          end
        end
      end
    end


    # Rather than putting a bunch of extra validation on illogical choices
    # (like conflicting :if_present and :if_absent), we'll let people
    # shoot themselves in the foot here.
    # This is meant for simple flow control; if you want to get fancy, you're
    # likely to get in trouble at some point anyway.
    def conditions_met?(document)
      return true if @prevalidations.empty?

      @prevalidations.each do |prevalidation|
        pass = prevalidation[:validator].validate(document.read_attribute(prevalidation[:attribute]))
        return false unless pass
      end

      true
    end
  end
end