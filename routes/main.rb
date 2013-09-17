module Chatlog
  class Application < Sinatra::Application
    get "/" do
      @active = ""
      @top_deaths = parse_top_deaths
      haml :main
    end

    get "/chatlog" do
      @active = "chatlog"
      @messages = parse_user_messages
      haml :chatlog
    end

    get "/chatlog.json" do
      content_type :json
      parse_full_log.to_json
    end

    private 

    def parse_top_deaths
      log = Chatlog::Parse.new(settings.server_log)
      log.parse.top_deaths
    end

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
