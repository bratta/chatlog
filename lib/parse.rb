module Chatlog
  class Parse
    attr_accessor :logfile, :output

    REGEX = {
      logline: /^(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d) \[(\w+)\] (.*)$/
    }
    SERVER_MESSAGES = [
      "Turned off", "Saving", "Saved", "Stopping", "Stopped", "Closing", "Closed", "Default game type", 
      "Generating", "Preparing", "Done (", "Starting", "Started", "Loading", "Turned on", "[Server]",
      "Setting", "Disconnecting"
    ]

    def initialize(logfile)
      @logfile = logfile
      @output = []
    end

    def parse
      @output = []
      if File.exist? @logfile
        IO.foreach(@logfile) do |line|
          line.match(REGEX[:logline]) do |m|
            @output << { timestamp: Time.parse(m[1]), severity: m[2], content: m[3] }
          end
        end
      else
        @output << { error: "Could not read '#{@logfile}'" }
      end
      self
    end

    def user_messages
      @output.reject do |message|
        message[:severity] != "INFO" ||
        message[:content].match(/^\[/) ||
        message[:content].match(/^\w+.*lost connection/) ||
        message[:content].match(/^\w+\[.*\] logged in with entity id/) ||
        SERVER_MESSAGES.any? { |sm| message[:content].index(sm) == 0 }
      end.map do |message|
        player, content = split_player_message(message[:content])
        { 
          timestamp: message[:timestamp],
          player: player,
          type: type_from_message(message[:content]),
          content: content
        }
      end
    end

    private

    def split_player_message(message)
      results = []
      message.match(/^<?(\w+)>?\s(.*)$/) do |m|
        results << m[1]
        results << m[2]
      end
      results = ["unknown", "error parsing message: #{message}"] if results.empty?
      results
    end

    def type_from_message(message)
      type = :death
      if message.match(/^</)
        type = :chat
      elsif message.match(/^\w+ (left|joined) the game$/)
        type = :join
      end
      type
    end
  end
end
