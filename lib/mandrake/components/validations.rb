module Mandrake
  module Validations
    extend ActiveSupport::Concern

    included do |base|
      base.send :include, ActiveModel::Validations
    end

    module ClassMethods
      def create_validations(key)
        validates_presence_of key.name if key.required
      end
    end
  end
end