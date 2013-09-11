require "bundler"
Bundler.require
require "yaml"
require "./parse.rb"

get "/" do
  content_type :json
  parse_log.to_json
end

def parse_log
  server_settings = YAML.load_file(File.join(settings.root, "config/minecraft.yml"))
  log = Chatlog::Parse.new(server_settings["server_log"])
  log.parse.user_messages
end
