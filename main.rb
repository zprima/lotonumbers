require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'colorize'

url1 = 'https://www.eloterija.si/results/loto/results.seam'
url2 = 'https://www.eloterija.si/results/loto/results.seam?page=2'
url3 = 'https://www.eloterija.si/results/loto/results.seam?page=3'

class Mathematician
  attr_accessor :numbers, :balllist

  def initialize(url = nil)
    @pool = (1..39).to_a
    @numbers = []
    @balllist = []
    @stats = {}
    @url = url
  end

  def math
    @free_numbers = @pool - @numbers
    @free_numbers_till_last_result = @pool - @balllist[1..-1].flatten.uniq
    @last_result = @balllist[0]

    @intersected_numbers = @free_numbers_till_last_result & @last_result

    @usage = ((@intersected_numbers.count.to_f / @free_numbers_till_last_result.count ) * 100.0).round(2)
    @curr = ((@intersected_numbers.count / 8.to_f) * 100.0).round(2).to_s + "%"

    @sorted_stats = @stats.sort_by{ |k, v|  -v }.to_h
  end

  def show_numbers
    puts 'Numbers on the page:'.yellow
    @balllist.each do |that_week_balllist|
      puts that_week_balllist.join(', ')
    end
  end

  def show_math
    puts 'Picked numbers'.yellow
    puts @numbers.sort.uniq.join(', ') + " (#{@numbers.uniq.count})"

    puts ''
    puts 'Free/Not picket:'.yellow
    puts @free_numbers.join(', ') + " (#{@free_numbers.count})"

    puts ''
    puts 'Free/Not picket last week:'.yellow
    puts @free_numbers_till_last_result.join(', ')

    puts ''
    puts 'Intersected numbers:'.yellow
    puts @intersected_numbers.join(', ')
    
    puts ''
    puts 'Usage from free till last session:'.yellow
    puts @usage.to_s + '%'
    
    puts ''
    puts 'Usage from the 8 picked ones:'.yellow
    puts @curr.to_s + '%'

    puts ''
    puts 'Sorted stats'.yellow
    puts @sorted_stats
  end

  def bias
    bias_elimination = [14, 18, 4, 28, 30, 33].sort
    bias_free_selection = @free_numbers - bias_elimination
    
    puts ('Bias elimination: (' + bias_elimination.join(', ') + ')').yellow
    puts bias_free_selection.join(', ')
  end
end

class Combiner < Mathematician
  def combine(numbers, balllist)
    @numbers = numbers
    @balllist = balllist

    @numbers.each do |num|
      @stats[num] = @stats[num].to_i + 1
    end

    math
  end
end

class Parser < Mathematician
  def parse
    doc = Nokogiri::HTML(open(@url))

    doc.css('.table-results .combolist ul li').each do |list_item|
      next unless list_item.css('.label').text == 'loto'

      that_week_numbers = []
      list_item.css('.balllist .ball').each do |ball|
        num = ball.text.to_i
        
        that_week_numbers << num
        @numbers << num

        @stats[num] = @stats[num].to_i + 1
      end

      @balllist << that_week_numbers
    end

    math
  end
end

p1 = Parser.new(url1)
p2 = Parser.new(url2)
p3 = Parser.new(url3)

p1.parse
p2.parse
p3.parse

puts ''
p1.show_numbers
puts ''
p1.show_math
puts ''
p1.bias

puts ''
puts '-----'.magenta

c = Combiner.new
c.combine(
  (p1.numbers + p2.numbers + p3.numbers).flatten,
  (p1.balllist + p2.balllist + p3.balllist),
)
puts ''
c.show_numbers
# c.show_math

