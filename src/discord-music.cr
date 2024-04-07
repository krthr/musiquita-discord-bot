require "dotenv"
Dotenv.load

require "kemal"
require "log"

require "./bot.cr"
require "./version.cr"

bot = DiscordMusic::Bot.new

get "/" do
  {
    discord_servers:       bot.discord_servers,
    chat_messages_history: bot.chat_messages_history,
  }.to_json
end

spawn do
  bot.start
end

PORT = if ENV["PORT"]?
         ENV["PORT"].to_i
       else
         3333
       end

Kemal.run(PORT)
