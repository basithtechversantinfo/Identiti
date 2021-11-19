module OktaAccount
  extend ActiveSupport::Concern
  require "uri"
  require "net/http"
  
  def create_okta_account request_body

      url = URI( ENV['OKTA_URL'] + "/api/v1/users?activate=true")

      https = Net::HTTP.new(url.host, url.port);
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["Authorization"] = "SSWS 00zCi3mHQHven1mh9ciYe6cOqvn6fbfIevbvdgkX1v"
      
      request.body = request_body.to_json
      response = https.request(request)
      puts response.read_body
  end
end