require 'telegram_bot'
require 'pp'
require 'logger'

logger = Logger.new(STDOUT, Logger::DEBUG)

bot = TelegramBot.new(token: 'you bot token', logger: logger)
logger.debug "starting telegram bot"
menu = [{"value" => "seafood"},{"value" => "food"},{"value" => "drink"},{"value" => "fruit"}]
your_order = []
help_user = "They call to menu delivery:
https://rubify.com

You can control me by sending these commands:

/show_menu - show list menu for order
/open_gift - Open a gift for you.
/goobye - Exit"
bot.get_updates(fail_silently: true) do |message|
  logger.info "@#{message.from.username}: #{message.text}"
  command = message.get_command_for(bot)

  message.reply do |reply|
    case command
    when /open_gift/i
      reply.text = "Congratulations #{message.from.first_name}! you have a cat from us :)"
    when /show_menu/i
      list_menu = ""
      menu.each_with_index do |item, index|
          list_menu += "\n"+(index+1).to_s+" - "+item["value"].capitalize
      end
      reply.text = "Hi #{message.from.first_name}!, Menu for today:"+ list_menu+"\nPlease select by command /get_item(index,index) \nExample: get 'Food' and 'Fruit' is /get_item(2,4)"
    when /get_item/i
      if command.include? "get_item("
        list_menu_order = ''
        number_item_arr = command[command.index('(')+1..-2]
        puts number_item_arr
        number_item_arr.split(',').each_with_index do |item, index|
            list_menu_order += "\n"+(index+1).to_s+" - "+menu[item.to_i-1]['value'].capitalize
        end
        reply.text = "Hi #{message.from.first_name}!, Your order today:"+ list_menu_order+"\nYour food will delivery about 1 hour later, Good have lunch!"
      end
    when /goobye/i
      reply.text = "For get me not, #{message.from.first_name}!"
    else
      reply.text = help_user
    end
    logger.info "sending #{reply.text.inspect} to @#{message.from.username}"
    reply.send_with(bot)
  end
end
