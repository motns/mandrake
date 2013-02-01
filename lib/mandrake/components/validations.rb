module Mandrake
  module Validations
    extend ActiveSupport::Concern

    module ClassMethods
      def create_validations(key)
        #validates_presence_of key.name if key.required
      end
    end
  end
end