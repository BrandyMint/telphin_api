TelphinApi.configure do |config|
  # Authorization parameters (not needed when using an external authorization):
  # config.app_key       = '123'
  # config.app_secret   = 'AbCdE654'
  # config.site = 'https://pbx.telphin.ru/uapi'
  
  # Faraday adapter to make requests with:
  # config.adapter = :net_http
  
  # Logging parameters:
  # log everything through the rails logger
  config.logger = Rails.logger
  
  # log requests' URLs
  # config.log_requests = true
  
  # log response JSON after errors
  # config.log_errors = true
  
  # log response JSON after successful responses
  # config.log_responses = false
end

# create a short alias TPH for TelphinApi module
# TelphinApi.register_alias
