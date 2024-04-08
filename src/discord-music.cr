require "dotenv"
Dotenv.load?

require "kemal"
require "log"

require "./bot.cr"
require "./version.cr"

bot = DiscordMusic::Bot.new

get "/" do
  {
    messages_history: bot.messages_history,
    cache:            bot.cache,
  }.to_json
end

spawn do
  bot.start
end

PORT = ENV.fetch("PORT", "3333").to_i
Kemal.run(PORT)
