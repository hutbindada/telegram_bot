open('./data/Order.txt', 'w') do |f|
  f.puts 'line'
end
File.truncate('./data/Order.txt', 0)