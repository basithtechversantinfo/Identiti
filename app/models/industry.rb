class Industry < ApplicationRecord
  default_scope { order('LOWER(title) ASC') }

  include VerificationAssociationsHasAndBelongsToMany

  validates_presence_of :title, :slug_id
  has_and_belongs_to_many :template_themes
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :surveys

  delegate :count, to: :template_themes
  alias_method :themes_count, :count
end
