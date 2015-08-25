# A rails generator `telphin_api:install`.
# It creates a config file in `config/initializers/telphin_api.rb`.
class TelphinApi::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  # Creates the config file.
  def create_initializer
    copy_file 'initializer.rb', 'config/initializers/telphin_api.rb'
  end
end
