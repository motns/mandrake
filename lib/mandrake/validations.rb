module Mandrake
  module Validations
    extend ActiveSupport::Concern

    included do |base|
      base.send :include, ActiveModel::Validations
    end
  end
end