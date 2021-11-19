class AddFullNameToRecipients < ActiveRecord::Migration[5.2]
  require 'faker'

  class Recipient < ApplicationRecord
  end

  def change
    add_column :recipients, :full_name, :string

    Recipient.find_each do |r|
      r.update(full_name: Faker::Name.unique.name)
    end
  end
end
