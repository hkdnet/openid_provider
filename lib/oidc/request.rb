require 'oidc/error_response'

module OIDC
  class Request
    # OpenIDConnectで定義されているパラメータ群
    ATTR = %i(client_id response_type redirect_uri state scope nonce display)
    attr_reader :client_id,
                :response_type,
                :redirect_uri,
                :state,
                :scope,
                :nonce,
                :display

    # error
    attr_reader :error

    def initialize(option)
      @client_id = option[:client_id]
      @response_type = option[:response_type]
      @redirect_uri = option[:redirect_uri]
      @state = option[:state]
      @scope = option[:scope]
      @nonce = option[:nonce]
      @display = option[:display]
    end

    def valid?
      validate
      @error.nil?
    end

    def scopes
      scope.nil? ? [] : scope.split(' ')
    end

    private

    def validate
      @error = nil
      %i(response_type redirect_uri scope state nonce).each do |e|
        break if @error
        unless send "validate_#{e}"
          @error = OIDC::ErrorResponse.send("build_#{e}_error")
        end
      end
    end

    def validate_response_type
      %w(id_token).include?(response_type)
    end

    def validate_redirect_uri
      # client_idに一致するclientがなかったらfalse
      has_client = true
      return false unless has_client
      # redirect_uriがclient.redirect_uriと一致するかどうか 一致→true, 不一致 false
      match_uri = true
      match_uri
    end

    def validate_scope
      # open_idを含み、なおかつ使えないものを含んでいなければよい
      scopes.include?('open_id')
    end

    def validate_state
      state.present?
    end

    def validate_nonce
      nonce.present?
    end
  end
end
