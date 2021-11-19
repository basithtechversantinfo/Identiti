class CategoriesSurvey < ApplicationRecord
  include RailsSortable::Model
  set_sortable :position

  default_scope { order(position: :asc) }

  belongs_to :category
  belongs_to :survey
end
