module Mandrake
  # Internal Mandrake error classes
  module Error
    # Used when the name for a key that's being defined is not valid
    class KeyNameError < StandardError; end
    # Used when there's a problem with embedding a single model
    class EmbedOneError < StandardError; end
    # Used when there's a problem with embedding multiple models
    class EmbedManyError < StandardError; end
  end
end