module Chatlog
  class Parse
    attr_accessor :logfile, :output, :tz

    REGEX = {
      logline: /^(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d) \[(\w+)\] (.*)$/
    }
    SERVER_MESSAGES = [
      "Turned off", "Saving", "Saved", "Stopping", "Stopped", "Closing", "Closed", "Default game type", 
      "Generating", "Preparing", "Done (", "Starting", "Started", "Loading", "Turned on", "[Server]",
      "Setting", "Disconnecting", "UUID of player"
    ]

    def initialize(logfile)
      @logfile = logfile
      @output = []
      @tz = TZInfo::Timezone.get("America/Chicago")
    end

    def parse
      @output = []
      if File.exist? @logfile
        IO.foreach(@logfile) do |line|
          line.match(REGEX[:logline]) do |m|
            @output << { timestamp: m[1], severity: m[2], content: m[3] }
          end
        end
      else
        @output << { error: "Could not read '#{@logfile}'" }
      end
      self
    end

    def user_messages(filter_private = true)
      self.parse if @output.empty?
      messages = @output.reject do |message|
        message[:severity] != "INFO" ||
        message[:content].match(/^\[/) ||
        message[:content].match(/^\w+.*lost connection/) ||
        message[:content].match(/^\w+\[.*\] logged in with entity id/) ||
        SERVER_MESSAGES.any? { |sm| message[:content].index(sm) == 0 }
      end.map do |message|
        player, content = split_player_message(message[:content])
        timestamp = Time.parse(message[:timestamp])
        tz_identifier = @tz.period_for_utc(timestamp).zone_identifier.to_s
        { 
          timestamp: @tz.utc_to_local(timestamp).strftime("%Y/%m/%d %I:%M %P ") + tz_identifier,
          player: player,
          type: type_from_message(message[:content]),
          content: content
        }
      end
      if filter_private
        messages.reject! {|message| message[:content].match(/^p\s+/i)}
      end
      messages
    end

    def top_deaths(n=10)
      self.parse if @output.empty?
      user_messages.select { |m| m[:type] == :death }.reduce({}) do |memo, m|
        memo[m[:player]] = memo[m[:player]].to_i + 1
        memo
      end.sort_by {|k,v| -v}.first(n)
    end

    private

    def split_player_message(message)
      results = []
      message.match(/^<?(\w+)>?\s(.*)$/) do |m|
        full_message, name, content = *m
        results << name
        results << content
      end
      if results.empty?
        message.match(/^\* (\w+)\s(.*)$/) do |m|
          results << m[1]
          results << "#{m[1]} #{m[2]}"
        end
      end
      results = ["unknown", "error parsing message: #{message}"] if results.empty?
      results
    end

    def type_from_message(message)
      type = :death
      if message.match(/^</)
        type = :chat
      elsif message.match(/^\* \w+/)
        type = :emote
      elsif message.match(/^\w+ has just earned the achievement/)
        type = :achievement
      elsif message.match(/^\w+ (left|joined) the game$/)
        type = :join
      end
      type
    end
  end
end
