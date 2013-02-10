module Mandrake
  class ValidationChain

    attr :continue_on_failure, :items, :conditions

    def initialize(params = {}, &block)
      @continue_on_failure = params[:continue_on_failure] ? params[:continue_on_failure] : false

      @conditions = []
      generate_conditions(params)

      @items = []

      instance_eval(&block) if block_given?
    end


    # Syntactic sugar for adding a Validation item to this chain
    def validate(validator, *args)
      add Mandrake::Validation.new(validator, *args)
    end


    # Syntactic sugar for adding a ValidationChain to this chain
    def chain(params = {}, &block)
      add Mandrake::ValidationChain.new(params, &block)
    end


    # Syntactic sugar for adding conditional chains

    def if_present(*args, &block)
      attributes, params = Mandrake::extract_params(*args)
      params = {:if_present => attributes}
      chain(params, block)
    end

    def if_absent(*attributes, &block)
      attributes, params = Mandrake::extract_params(*args)
      params = {:if_absent => attributes}
      chain(params, block)
    end


    def add(*items)
      items.each do |item|
        unless item.is_a?(::Mandrake::Validation) || item.is_a?(::Mandrake::ValidationChain)
          raise ArgumentError, "Validator chain item has to be a Validator or another ValidationChain"
        end

        @items << item
      end

      items.last
    end


    def run(document)
      return true unless conditions_met?(document)

      success = true

      @items.each do |item|
        validation_success = item.run(document)
        success = success && validation_success
        break unless @continue_on_failure || success
      end

      success
    end


    # Rather than putting a bunch of extra validation on illogical choices
    # (like conflicting :if_present and :if_absent), we'll let people
    # shoot themselves in the foot here.
    # This is meant for simple flow control; if you want to get fancy, you're
    # likely to get in trouble at some point anyway.
    def conditions_met?(document)
      return true if @conditions.empty?

      @conditions.each do |condition|
        pass = condition[:validator].validate(document.read_attribute(condition[:attribute]))
        return false unless pass
      end

      true
    end


    protected

      def generate_conditions(conditions)
        if conditions.key? :if_present
          if conditions[:if_present].respond_to?(:to_sym) # single field
            @conditions << {
              :validator => ::Mandrake::Validator::Presence,
              :attribute => conditions[:if_present]
            }
          elsif conditions[:if_present].is_a?(Array)
            conditions[:if_present].each do |attribute|
              @conditions << {
                :validator => ::Mandrake::Validator::Presence,
                :attribute => attribute
              }
            end
          end
        end

        if conditions.key? :if_absent
          if conditions[:if_absent].respond_to?(:to_sym) # single field
            @conditions << {
              :validator => ::Mandrake::Validator::Absence,
              :attribute => conditions[:if_absent]
            }
          elsif conditions[:if_absent].is_a?(Array)
            conditions[:if_absent].each do |attribute|
              @conditions << {
                :validator => ::Mandrake::Validator::Absence,
                :attribute => attribute
              }
            end
          end
        end
      end

    # end protected
  end
end