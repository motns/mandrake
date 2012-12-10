module Mandrake
  module Document
    extend ActiveSupport::Concern

    COMPONENTS = [
      Mandrake::Keys
    ]

    included do |base|
      COMPONENTS.each do |component|
        base.send :include, component
      end
    end
  end
end