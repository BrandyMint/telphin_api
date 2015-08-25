require 'bundler/setup'
require 'sinatra'
require 'telphin_api'

class OmniTelphinDemo < Sinatra::Base
  use Rack::Session::Cookie

  TelphinApi.configure do |config|
    # Authorization parameters (not needed when using an external authorization):
    config.app_key      = 'F~PUJXc8X5_2vUy7W5B~IBjXm6Hv~dRT'
    config.app_secret   = 'x~X1r206MB~ckpYhb6c.W4ch4OLx_9If'
  end

  get '/' do
    @tph = TelphinApi.authorize
    ar = @tph.extensions.phone_call_events(:user_id => '@me', :extension_number => '17608s*101', :method => :get)

    abort ar.inspect
  end

end

OmniTelphinDemo.run!