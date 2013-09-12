module Chatlog
  class Application < Sinatra::Application
    get "/" do
      haml :main
    end

    get "/chatlog" do
      @messages = parse_user_messages
      haml :chatlog
    end

    get "/chatlog.json" do
      content_type :json
      parse_full_log.to_json
    end

    private 

    def parse_user_messages
      log = Chatlog::Parse.new(settings.server_log)
      log.parse.user_messages
    end

    def parse_full_log
      log = Chatlog::Parse.new(settings.server_log)
      log.parse.output
    end
  end
end
