module Mandrake
  class Validation

    attr :validator_name, :validator_class, :attributes, :params

    def initialize(validator, *args)
      raise ArgumentError, "Validator name should be provided as a Symbol, #{validator.class.name} given" unless validator.respond_to?(:to_sym)

      @validator_class = Mandrake::Validator.get_class(validator)
      raise ArgumentError, "Unknown validator: #{validator}" if @validator_class.nil?

      @validator_name = validator.to_sym

      @attributes, @params = Mandrake::extract_params(*args)

      @attributes.map! do |attribute|
        raise ArgumentError, "Attribute name has to be a Symbol, #{attribute.class.name} given" unless attribute.respond_to?(:to_sym)
        attribute.to_sym
      end
    end


    def run(document)
      values = @attributes.collect {|a| document.read_attribute(a) }

      if @validator_class.validate(*values, @params)
        true
      else
        document.failed_validators.add(
          @attributes,
          @validator_name,
          @validator_class.last_error,
          @validator_class.last_error_code
        )
        false
      end
    end
  end
end