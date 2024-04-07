require "dotenv"
require "log"

Dotenv.load

require "./bot.cr"

module DiscordMusic
  VERSION = "0.1.0"
end

bot = DiscordMusic::Bot.new
bot.start
