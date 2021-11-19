class TemplateTheme < ApplicationRecord
  belongs_to :account
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :industries
  has_many :surveys, dependent: :nullify
  has_many :categories_template_themes, dependent: :destroy

  validates_presence_of :title

  # before_destroy :check_association_survey

  # def check_association_survey
  #   errors.clear
  #     if self.class.reflect_on_all_associations(:has_many).map{|a| a.name }.include?(:surveys)
  #       errors.add :base, :delete_association,
  #                  model:            "Survey Theme",
  #                  association_name: self.class.human_attribute_name("Surveys").downcase
  #     end
  #
  #   throw :abort if errors.any?
  # end
end
