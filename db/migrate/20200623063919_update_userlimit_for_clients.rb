class UpdateUserlimitForClients < ActiveRecord::Migration[5.2]
  def change
  	clients = Account.where(admin: false, account_type: 'client')

  	clients.each do |client|
  		unless client.blank?	
	  	  puts "client id: #{client.id}"
	      user_limit = client.users.where(archived: false).count + 1
	      client.user_limit = user_limit unless user_limit == 0
	      client.save
  		end
  	end

  end
end
