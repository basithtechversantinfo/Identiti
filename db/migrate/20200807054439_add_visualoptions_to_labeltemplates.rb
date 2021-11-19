class AddVisualoptionsToLabeltemplates < ActiveRecord::Migration[5.2]
  def change
  	single = LabelTemplate.new(title: 'Single Select', description: '', default_type: 'system-custom', slug_id: 'system-custom3')
  	multiple = LabelTemplate.new(title: 'Multiple Select', description: '', default_type: 'system-custom', slug_id: 'system-custom4')
  	single.save(validate: false)
  	multiple.save(validate: false)
  end
end
