module TelphinApi
  # A class representing a connection to Telphin. It holds the access token.
  class Client
    include Resolver

    # Значение маркера доступа. Это значение используется при выполнении запросов к API.
    # @return [String]
    attr_reader :token

    # Тип маркера. Допустимо только значение Bearer.
    # @return [String]
    attr_reader :token_type

    # Новый маркер, который можно использовать для обновления маркера с истекшим сроком действия.
    # @return [String]
    attr_reader :refresh_token

    # Срок действия маркера доступа (в секундах).
    # @return [Time]
    attr_reader :expires_in

    # A new API client.
    # If given an `OAuth2::AccessToken` instance, it extracts and keeps
    # the token string, the user id and the expiration time;
    # otherwise it just stores the given token.
    # @param [String, OAuth2::AccessToken] token An access token.
    def initialize(token = nil)
      if token.respond_to?(:token) && token.respond_to?(:params)
        # token is an OAuth2::AccessToken
        @token = token.token
        @token_type = token.params['token_type']
        @refresh_token = token.params['refresh_token']
        @expires_in = Time.now + token.expires_in unless token.expires_in.nil?
      else
        # token is a String or nil
        @token = token
      end
    end

    # Is a `TelphinApi::Client` instance authorized.
    def authorized?
      !@token.nil?
    end

    # Did the token already expire.
    def expired?
      @expires_in && @expires_in < Time.now
    end

    # Called without arguments it returns the `execute` namespace;
    # called with arguments it calls the top-level `execute` API method.
    def execute(*args)
      if args.empty?
        create_namespace(:execute)
      else
        call_method([:execute, *args])
      end
    end

    # If the called method is a namespace, it creates and returns a new `TelphinApi::Namespace` instance.
    # Otherwise it creates a `TelphinApi::Method` instance and calls it passing the arguments and a block.
    def method_missing(*args, &block)
      if Namespace.exists?(args.first)
        create_namespace(args.first)
      else
        call_method(args, &block)
      end
    end

    private
    def settings
      @settings ||= self.get_user_settings
    end
  end
end
