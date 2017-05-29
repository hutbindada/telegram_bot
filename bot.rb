require 'telegram_bot'
require 'pp'
require 'logger'
require 'httparty'

logger = Logger.new(STDOUT, Logger::DEBUG)
token = '218095932:AAFsqSbGBnKcfAVQIeqMud2J_jR9K42Ugtw'
bot = TelegramBot.new(token: '218095932:AAFsqSbGBnKcfAVQIeqMud2J_jR9K42Ugtw', logger: logger)
@group_id = -181166874
@url = "https://api.telegram.org/bot#{token}/sendMessage"
logger.debug "starting telegram bot"
your_order = []
help_admin = "Functions avaliable for admin
You can control me by sending these commands:

/post_group - Post order today to group order food
/in_progress ....."

def config_notice(is_allow, message)
  reply_str = ""
  list_users = []
  open("data/User.txt", "r") do |f|
    f.each_line do |line|
      list_users << line.split('=')[0]
    end
  end
  user_id = message.from.id.to_s
  full_name = get_full_name(message)
  if is_allow == 0
    if list_users.include? user_id
      remove_user(user_id)
      reply_str = "It's sad that you have chosen to disable notifications from me. If you need any alerts again, enter /enable_notice to allow me to send you alerts."
    else
      reply_str = "Hello #{full_name}, you have not enabled notifications from RubifyEATS at the moment. Enter /enable_notice to enable notifications."
    end
  elsif is_allow == 1
    if list_users.include? user_id
      reply_str = "You have already enabled notifications from RubifyEATS. Don't worry, I will be informing you of all alerts."
    else
      open('data/User.txt', 'a') do |f|
        f.puts user_id + '=' + full_name
      end
      reply_str = "Great! I can now send you notifications. Stay tuned!"
    end
  end
  reply_str
end

def message_for_user(message)
  if check_user_exist(message)
    msg = [
      "Hello #{get_full_name(message)}, welcome to RubifyEATS!\n",
      "Talk to me by sending these commands:\n",
      "/show_menu - Show list of dishes to order",
      "/disable_notice - To disable notification from bot (every working days)"
    ].join("\n")
  else
    msg = [
      "Hello #{get_full_name(message)}, welcome to RubifyEATS!\n",
      "Talk to me by sending these commands:\n",
      "/show_menu - Show list of dishes to order",
      "/enable_notice - To enable notification from bot (every working days)"
    ].join("\n")
  end
  msg
end

def check_user_exist(message)
  list_users = []
  open("data/User.txt", "r") do |f|
    f.each_line do |line|
      list_users << line.split('=')[0]
    end
  end
  user_id = message.from.id.to_s
  if list_users.include? user_id
    true
  else
    false
  end
end

def get_menu
  list_cm = ["\nCÔ MAI ===================================\n\n"]
  list_om = ["\nÔNG MẬP ==================================\n\n"]
  list_nq = ["\nNGÔ QUYỀN ================================\n\n"]
  open("data/Menu.txt", "r") do |f|
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
  list_menu = [
    "Here's the menu for today! Click on your order\n",
    list_nq.join(""),
    list_cm.join(""),
    list_om.join(""),
    "\n\nJust click to order code above for take an order"
  ].join("")
  list_menu
end

def get_hash_menu
  list_menu = {}
  File.open("data/Menu.txt", "r") do |f|
    f.each_line do |line|
      key = line.split('=')[0]
      value = line.split('=')[1]
      list_menu[key] = value
    end
  end
  list_menu
end

def get_hash_order
  list_order = {}
  File.open("data/Order.txt", "r") do |f|
    f.each_line do |line|
      key = line.split('=')[0]
      value = [
        line.split('=')[1],
        line.split('=')[2],
        line.split('=')[3]
      ].join('=')
      list_order[key] = value
    end
  end
  list_order
end

def save_to_order(item)
  open('data/Order.txt', 'a') do |f|
    f.puts item
  end
end

def get_full_name(msg)
  msg.from.first_name || "" + ' ' + msg.from.last_name || ""
end

def change_order(user, food_name, food_id)
  content_change = []
  open("data/Order.txt", "r") do |f|
    f.each_line do |line|
      if line.split('=')[0] == user.from.id.to_s
        new_line = [
          line.split('=')[0],
          food_id,
          line.split('=')[2],
          food_name
        ].join('=')
        content_change.push(new_line)
      else
        content_change.push(line)
      end
    end
  end
  File.truncate('data/Order.txt', 0)
  open('data/Order.txt', 'a') do |f|
    content_change.each do |line|
      f.puts line
    end
  end
end

def remove_user(user_id)
  list_change = []
  open("data/User.txt", "r") do |f|
    f.each_line do |line|
      if line.split('=')[0] != user_id.to_s
        list_change.push(line)
      end
    end
  end
  File.truncate('data/User.txt', 0)
  open('data/User.txt', 'a') do |f|
    list_change.each do |line|
      f.puts line
    end
  end
end

def delete_my_order(user_id)
  list_change = []
  open("data/Order.txt", "r") do |f|
    f.each_line do |line|
      if line.split('=')[0] != user_id.to_s
        list_change.push(line)
      end
    end
  end
  File.truncate('data/Order.txt', 0)
  open('data/Order.txt', 'a') do |f|
    list_change.each do |line|
      f.puts line
    end
  end
end

def post_to_group
  list_cm = ["\nCô Mai ===================================\n\n"]
  list_om = ["\nÔng Mập ==================================\n\n"]
  list_nq = ["\nNgô Quyền ================================\n\n"]
  open("data/Order.txt", "r") do |f|
    f.each_line do |line|
      arr_line = line.split('=')
      if arr_line[1].include? "OM"
        list_om << "\xF0\x9F\x91\x89" + arr_line[2] + ': ' + arr_line[3]
      elsif arr_line[1].include? "NQ"
        list_nq << "\xF0\x9F\x91\x89 " + arr_line[2] + ': ' + arr_line[3]
      elsif arr_line[1].include? "CM"
        list_cm << "\xF0\x9F\x91\x89 " + arr_line[2] + ': ' + arr_line[3]
      end
    end
  end
  menu_to_group = list_nq.join("") + list_cm.join("") + list_om.join("")
  HTTParty.post(@url, {
    body: {
      chat_id: @group_id,
      text: menu_to_group
    }
  })
end

def valid_date_time?
  Time.now.wday.between?(1,5) && Time.now.hour.between?(8,11)
end

bot.get_updates(fail_silently: true) do |message|
  logger.info "@#{message.from.username}: #{message.text}"
  command = message.get_command_for(bot)

  message.reply do |reply|
    if message.chat.id == @group_id
      reply.text = "Hello #{get_full_name(message)}, please send your orders to RubifyEATS instead. This Group is only meant for putting all the orders together in one view. Thanks!"
    elsif command == "/start"
      reply.text = message_for_user(message)
    elsif !valid_date_time?
      reply.text = "Oops, I'm unable to take your orders for food at the moment. You can only order during working days from 8am to 11am. Sorry!"
    else
      case command
      when /EAT/i
        list_order = get_hash_order
        list_menu = get_hash_menu
        if list_order[message.from.id.to_s].nil?
          # New order
          # id=order_code=ful_name=food_name
          item = [
            message.from.id.to_s,
            command,
            get_full_name(message),
            list_menu[command]
          ].join('=')
          save_to_order(item)
          reply.text = [
            "Your have selected: ",
            list_menu[command],
            "\nIf you would like to add special instructions to your order, please type /add (your request)",
            "\nExample: /add (more sauce, less spicy, more rice, etc)"
          ].join('')
          post_to_group
        else
          # Exist Order
          change_order(message, list_menu[command], command)
          reply.text = [
            "You have changed your order to: ",
            list_menu[command],
            "\nIf you would like to add special instructions to your order, please type /add (your request)",
            "\nExample: /add (more sauce, less spicy, more rice, etc)"
          ].join('')
          post_to_group
        end
      when /disable_notice/i
        reply.text = config_notice(0, message)
      when /enable_notice/i
        reply.text = config_notice(1, message)
      when /post_group/i
        post_to_group
      when /add/i
        if command != '/add'
          list_order = get_hash_order
          list_menu = get_hash_menu
          if list_order[message.from.id.to_s].nil?
            reply.text = [
              "Wait a minute, you haven't sent an order. Please send an order first, before letting me know the special instructions you need.\n",
              get_menu
            ].join("\n")
          else
            plus_item = command[command.index('(')..-1]
            your_order = list_order[message.from.id.to_s]
            menu_id = your_order.split('=')[0]
          
            order_text = your_order.split('=')[2].split('(')[0][0..-2].concat(plus_item)
            change_order(message, order_text, menu_id)
            reply.text = [
              "Your changed to: ",
              order_text,
              "\n\nIf you want to add more something or change, please typing in chat:\n/add(more food, less rice, etc)"
            ].join('')
            post_to_group
          end
        else
          reply.text = "Wrong! Type /add(something...) please type in chat with option (something you want to add)"
        end
      when /admin/i
        reply.text = help_admin
      when /delete/i
        delete_my_order(message.from.id)
        reply.text = "Deleted!"
        post_to_group
      else
        reply.text = get_menu
      end
    end
    logger.info "sending #{reply.text.inspect} to @#{message.from.username}"
    reply.send_with(bot)
  end
end
