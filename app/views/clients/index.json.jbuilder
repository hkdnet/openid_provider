json.array!(@clients) do |client|
  json.extract! client, :id, :name, :client_id, :client_secret, :redirect_uri
  json.url client_url(client, format: :json)
end
