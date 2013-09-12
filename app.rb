require 'bundler'
Bundler.require
require 'yaml'
require 'time'
require_relative 'lib/parse'

module Chatlog
  class Application < Sinatra::Application
    configure :production do
      set :haml, ugly: true
      set :clean_trace, true
    end

    configure do
      server_settings = YAML.load_file(File.join(settings.root, "config/minecraft.yml"))
      set :server_log, server_settings["server_log"]
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end
  end
end

require_relative 'helpers/init'
require_relative 'routes/init'
