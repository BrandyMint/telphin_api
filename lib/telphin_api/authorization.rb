module TelphinApi
  # A module containing the methods for authorization.
  #
  # @note `TelphinApi::Authorization` extends `TelphinApi` so these methods should be called from the latter.
  module Authorization
    # Authorization options.
    OPTIONS = {
        client: {
            token_url: '/oauth/token.php'
        },
        client_credentials: {
            'auth_scheme' => 'request_body'
        }
    }

    # Not used for this strategy
    #
    # @raise [NotImplementedError]
    def authorization_url
      fail(NotImplementedError, 'The authorization endpoint is not used in this strategy')
    end

    # Authorization (getting the access token and building a `TelphinApi::Client` with it).
    # @raise [ArgumentError] raises after receiving an unknown authorization type.
    # @return [TelphinApi::Client] An API client.
    def authorize(options = {})
      options[:client_id] ||= TelphinApi.app_key
      options[:client_secret] ||= TelphinApi.app_secret
      token = client.client_credentials.get_token(options, OPTIONS[:client_credentials].dup)
      Client.new(token)
    end

    private
    def client
      @client ||= OAuth2::Client.new(TelphinApi.app_key, TelphinApi.app_secret, {site: TelphinApi.site}.merge(OPTIONS[:client]))
    end
  end
end
