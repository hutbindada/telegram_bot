require 'httparty'
require 'telegram_bot'
require 'pp'
require 'logger'

logger = Logger.new(STDOUT, Logger::DEBUG)
token = '218095932:AAFsqSbGBnKcfAVQIeqMud2J_jR9K42Ugtw'
bot = TelegramBot.new(token: '218095932:AAFsqSbGBnKcfAVQIeqMud2J_jR9K42Ugtw', logger: logger)
group_id = -181166874
url = "https://api.telegram.org/bot#{token}/sendMessage"

HTTParty.post(url, {
  body: {
    chat_id: group_id,
    text: "test."
  }
})