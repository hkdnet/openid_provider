require 'uri'
require 'url_safe_base64'

module OIDC
  class Response
    attr_accessor :owner, :scope
    attr_reader :client_id, :redirect_uri, :token_type, :state, :nonce

    def initialize(option)
      @client_id = option[:client_id]
      @redirect_uri = option[:redirect_uri]
      # 固定
      @token_type = 'Bearer'
      @state = option[:state]
      @nonce = option[:nonce]
      @scope = option[:scope]
    end

    def build_response
      uri = URI.parse(@redirect_uri)
      uri.fragment = build_params
      uri.to_s
    end

    def build_params
      %i(token_type id_token state).map { |e| "#{e}=#{send(e)}" }.join('&')
    end

    def id_token
      payload = UrlSafeBase64.encode64(token_data.to_json)
      data = "#{header}.#{payload}"
      signature = UrlSafeBase64.encode64(pkey.sign('sha256', data))
      "#{data}.#{signature}"
    end

    def header
      UrlSafeBase64.encode64(({ typ: 'JWT', alg: 'RS256' }).to_json)
    end

    def token_data
      issue_at = Time.now.to_i
      id_token_expire = 10 * 60 * 1000
      exp = issue_at + id_token_expire
      issuer = 'sample_oidc_provider'
      { iss: issuer,
        sub: owner,
        aud: @client_id,
        exp: exp,
        iat: issue_at,
        nonce: @nonce,
        userinfo: userinfo }
    end

    def userinfo
      { name: 'test' }
    end

    def pkey
      OpenSSL::PKey::RSA.new(File.read(ENV['OIDC_PKEY_PATH']))
    end
  end
end
