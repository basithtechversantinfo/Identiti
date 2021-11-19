class Category < ApplicationRecord
  include RailsSortable::Model
  set_sortable :position

  default_scope { order(position: :asc) }

  belongs_to :account
  belongs_to :survey, optional: true
  has_and_belongs_to_many :template_themes
  has_and_belongs_to_many :industries
  has_many :questions, dependent: :destroy
  has_many :categories_surveys, dependent: :destroy

  validates_presence_of :title

  # before_destroy :check_association_template_themes

  def check_association_template_themes
    errors.clear
    if self.class.reflect_on_all_associations(:has_and_belongs_to_many).map{|a| a.name }.include?(:template_themes)
      errors.add :base, :delete_association,
                 model:            "Block",
                 association_name: self.class.human_attribute_name("Survey Themes").downcase
    end

    throw :abort if errors.any?
  end
end
