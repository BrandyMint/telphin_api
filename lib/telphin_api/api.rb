module TelphinApi
  # A low-level module which handles the requests to Telphin API and returns their results as mashes.
  #
  # It uses Faraday with middleware underneath the hood.
  module API
    class << self
      # API method call.
      # @param [String] full_method A full name of the method.
      # @param [Hash] args Method arguments.
      # @param [String] token The access token.
      # @return [Hashie::Mash] Mashed server response.
      def call(full_method, args = {}, token = nil)
        namespace = full_method.first
        action = full_method.last

        http_method = args.delete(:http_method)
        http_method ||= :get

        user_id = args.delete(:user_id)
        extension_number = args.delete(:extension_number)

        url_options = args.delete(:url_options)
        url_options ||= []
        url = [namespace, user_id, extension_number, action].concat(url_options).join('/')

        flat_arguments = Utils.flatten_arguments(args)
        flat_arguments = flat_arguments.to_json.to_s if [:post, :put].include? http_method

        connection(url: TelphinApi.site, token: token, method: http_method).send(http_method, url, flat_arguments).body
      end

      # Faraday connection.
      # @param [Hash] options Connection options.
      # @option options [String] :url Connection URL (either full or just prefix).
      # @option options [String] :token OAuth2 access token (not used if omitted).
      # @return [Faraday::Connection] Created connection.
      def connection(options = {})
        url = options.delete(:url)
        token = options.delete(:token)
        method = options.delete(:method)

        Faraday.new(url, TelphinApi.faraday_options) do |builder|
          builder.headers['Authorization'] = "Bearer #{token}"
          builder.headers['Content-Type'] = 'application/json' if [:post, :put].include? method

          builder.request :multipart
          builder.request :url_encoded
          builder.request :retry, TelphinApi.max_retries

          builder.response :telphin_logger
          builder.response :mashify
          builder.response :multi_json, preserve_raw: true

          builder.adapter TelphinApi.adapter
        end
      end
    end
  end
end
