module Chatlog
  class Application < Sinatra::Application
    get "/" do
      haml :main
    end

    get "/chatlog" do
      @messages = parse_user_messages
      haml :chatlog
    end

    private 

    def parse_user_messages
      server_settings = YAML.load_file(File.join(settings.root, "config/minecraft.yml"))
      log = Chatlog::Parse.new(server_settings["server_log"])
      log.parse.user_messages
    end
  end
end
