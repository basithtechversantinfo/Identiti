json.extract! recipient, :id, :account, :list_id, :email, :created_at, :updated_at
json.url recipient_url(recipient, format: :json)
