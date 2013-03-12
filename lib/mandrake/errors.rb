module Mandrake
  # Internal Mandrake error classes
  module Error
    # Used when the name for a key that's being defined is not valid
    class KeyNameError < StandardError; end
    # Used when the alias for a key that's being defined is not valid
    class KeyAliasError < StandardError; end
  end
end