require 'nokogiri'
require 'open-uri'
require 'byebug'

url = 'https://www.eloterija.si/results/loto/results.seam'
doc = Nokogiri::HTML(open(url))

pool = (1..39).to_a

numbers = []

doc.css('.table-results .combolist ul li').each do |list_item|
  next unless list_item.css('.label').text == 'loto'

  that_week_numbers = []
  list_item.css('.balllist .ball').each do |ball|
    num = ball.text.to_i
    
    that_week_numbers << num
    numbers << num
  end

  puts that_week_numbers.join(' ')
end

puts ''
puts numbers.sort.uniq.join(' ')

free_numbers = pool - numbers
puts free_numbers.join(' ')


# Example output
# 2 7 8 17 19 29 35 38
# 3 7 20 22 25 26 36 23
# 7 8 13 17 23 26 32 16
# 7 10 13 19 24 28 35 34
# 5 12 13 15 16 21 27 25

# 2 3 5 7 8 10 12 13 15 16 17 19 20 21 22 23 24 25 26 27 28 29 32 34 35 36 38
# 1 4 6 9 11 14 18 30 31 33 37 39
