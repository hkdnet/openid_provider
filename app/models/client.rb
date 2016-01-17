class Client < ActiveRecord::Base
  class << self
    def valid_redirect_uri?(client_id, redirect_uri)
      client = Client.find_by(client_id: client_id)
      !client.nil? && client.redirect_uri == redirect_uri
    end
  end
end
