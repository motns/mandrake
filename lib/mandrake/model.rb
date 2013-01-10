require 'mandrake/component/dirty'
require 'mandrake/component/keys'

module Mandrake
  module Model
    extend ActiveSupport::Concern

    COMPONENTS = [
      Mandrake::Keys,
      Mandrake::Dirty
    ]


    included do |base|
      COMPONENTS.each do |component|
        base.send :include, component
      end
    end


    module ClassMethods
      def model_methods_module
        @model_methods_module ||= begin
          mod = Module.new
          include(mod)
          mod
        end
      end
    end
  end
end