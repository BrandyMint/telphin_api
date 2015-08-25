require 'faraday'
require 'faraday_middleware'
require 'oj' unless defined?(JRUBY_VERSION)
require 'faraday_middleware/multi_json'
require 'oauth2'
require 'yaml'
require 'hashie'

require 'telphin_api/version'
require 'telphin_api/error'
require 'telphin_api/configuration'
require 'telphin_api/authorization'
require 'telphin_api/utils'
require 'telphin_api/api'
require 'telphin_api/resolver'
require 'telphin_api/resolvable'
require 'telphin_api/client'
require 'telphin_api/namespace'
require 'telphin_api/method'
require 'telphin_api/result'
require 'telphin_api/logger'

# Main module.
module TelphinApi
  extend TelphinApi::Configuration
  extend TelphinApi::Authorization

  class << self
    # Creates a short alias `TPH` for `TelphinApi` module.
    def register_alias
      Object.const_set(:TPH, TelphinApi)
    end
    
    # Removes the `TPH` alias.
    def unregister_alias
      Object.send(:remove_const, :TPH) if defined?(TPH)
    end
  end
end
