module Mandrake
  module Type
    # This is just a base Type that all Numeric classes (Integer, Float, etc.)
    # inherit from. You'd never actually use the Numeric Type class directly.
    class Numeric < Base
      # Default parameters for this Type, processed by {Mandrake::Type::Base.params}.
      PARAMS = {:in => nil}
    end
  end
end