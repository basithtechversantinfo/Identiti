class AddDefaultTypeToLabelTemplates < ActiveRecord::Migration[5.2]
  class LabelTemplate < ApplicationRecord
  end

  def change
    add_column :label_templates, :default_type, :string, default: 'user-custom'
    add_column :label_templates, :slug_id, :string, default: 'user-slug-id'

    LabelTemplate.find_or_create_by(title: 'Custom', description: '', default_type: 'system-custom', slug_id: 'system-custom1')
    LabelTemplate.find_or_create_by(title: 'Custom with scores', description: '', default_type: 'system-custom', slug_id: 'system-custom2')
  end
end
