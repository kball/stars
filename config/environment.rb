#RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'

  if defined? JRUBY_VERSION
    # Patch Rails Framework
    require 'rails_appengine'
    # Use DataMapper to access datastore
    require 'rails_dm_datastore'
    # Set Logger from appengine-apis, all environments
    require 'appengine-apis/logger'
    config.logger = AppEngine::Logger.new
    # Skip frameworks you're not going to use.
    config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  end
  # Skip plugin locators
  config.plugin_locators -= [Rails::Plugin::GemLocator]

  config.action_mailer.default_url_options ||= {:host => 'localhost:3000'}
end

ActionView::Helpers::AssetTagHelper.
    register_javascript_expansion :jquery => [
  'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js',
  'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js'
]

