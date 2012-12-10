class Trip
  include Mandrake::Document

  key :title, String, :required => true, :length => 10..100
  key :is_listed, Boolean, :required => false, :default => true

  # Embed a structure (Hash), under a given Key
  embed :image, :as => :Image # ":as" optional
  # embed many structures, under given Key
  embed_many :snip, :as => :Snips # ":as"
  ###


  ###########
  # Scopes
  # (optional) default scope
  default_scope {:is_listed => true}
  # additional named scope
  scope :archived, {:is_archived => true}
  # parametrised scope
  scope :


  ###########
  # Views

  default_view {:snips => -1}
  # named scope (with field exclusion)
  view :header, {:name => 1}

end