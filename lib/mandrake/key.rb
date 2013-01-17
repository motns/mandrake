module Mandrake
  class Key
    attr :name, :alias, :type, :params

    def initialize(name, type, opt = {})
      @name = name
      @alias = (opt[:as] || name).to_sym

      @params = {}
      @params[:required] = opt[:required] || false
      @params[:default] = opt[:default] || nil

      klass = Mandrake::Type.get_class(type)
      raise "Unknown Mandrake type #{type}" if klass.nil?

      @type = klass

      klass.params.each do |param, default|
        @params[param] = opt[param] || default
      end
    end

    def required
      @params[:required]
    end

    def default
      @params[:default]
    end
  end
end