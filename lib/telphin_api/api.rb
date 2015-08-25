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

        http_method = args.delete(:method)
        http_method ||= :get

        user_id = args.delete(:user_id)
        extension_number = args.delete(:extension_number)
        id = args.delete(:id)

        flat_arguments = Utils.flatten_arguments(args)
        url = [TelphinApi.site, namespace, user_id, extension_number, action].join('/')
        url = url + '/' + id unless id.nil?
        connection = connection(url: url, token: token)

        if flat_arguments.empty?
          connection.send(http_method).body
        else
          connection.send(http_method, flat_arguments).body
        end
      end

      # Faraday connection.
      # @param [Hash] options Connection options.
      # @option options [String] :url Connection URL (either full or just prefix).
      # @option options [String] :token OAuth2 access token (not used if omitted).
      # @return [Faraday::Connection] Created connection.
      def connection(options = {})
        url = options.delete(:url)
        token = options.delete(:token)
        url = url + '?accessRequestToken=' + token

        Faraday.new(url, TelphinApi.faraday_options) do |builder|
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
