# encoding: utf-8
require 'httparty'
require 'telegram_bot'
require 'pp'
require 'logger'

logger = Logger.new(STDOUT, Logger::DEBUG)
token = '218095932:AAFsqSbGBnKcfAVQIeqMud2J_jR9K42Ugtw'
bot = TelegramBot.new(token: '218095932:AAFsqSbGBnKcfAVQIeqMud2J_jR9K42Ugtw', logger: logger)
group_id = -181166874
url = "https://api.telegram.org/bot#{token}/sendMessage"

list_users = []
alert_msg = ", Would you like to eat something"
def get_menu
  list_cm = ["\nCô Mai ===================================\n\n"]
  list_om = ["\nÔng Mập ==================================\n\n"]
  list_nq = ["\nNgô Quyền ================================\n\n"]
  open("data/Menu.txt", "r:UTF-8") do |f|
    f.each_line do |line|
      arr_line = line.split('=')
      if arr_line[0].include? "OM"
        list_om << arr_line.join(' ')
      elsif arr_line[0].include? "NQ"
        list_nq << arr_line.join(' ')
      elsif arr_line[0].include? "CM"
        list_cm << arr_line.join(' ')
      end
    end
  end
  list_menu = list_nq.join("") + list_cm.join("") + list_om.join("")
  list_menu
end

def list_user_ordered
  arr_orders = []
  open("data/Order.txt", "r:UTF-8") do |f|
    f.each_line do |line|
      arr_orders << line.split('=')[0]
    end
  end
  arr_orders
end

open("data/User.txt", "r:UTF-8") do |f|
  f.each_line do |line|
    list_users << line
  end
end

list_users.each do |user|
  list_ordered = list_user_ordered
  user_id = user.split('=')[0]
  unless list_ordered.include? user_id
    HTTParty.post(url, {
      body: {
        chat_id: user_id,
        text: 'Hi ' + user.split('=')[1][0..-2] + alert_msg + "\n" + get_menu
      }
    })
  end
end
