require 'nokogiri'
require 'open-uri'
doc = Nokogiri::HTML(open("http://www.usatoday.com/experience/america/best-of-lists/10best-rock-and-roll-hotels-around-the-usa/15676735/"))

c = 0
found_counter = 0

doc.css('img').each do |i|
    src_url = doc.css('img')[c]['src'].to_s
    alt_text = doc.css('img')[c]['alt'].to_s
    if src_url.empty?
      puts "empty"
    else
      found_counter += 1
      puts "Found counter is: #{found_counter}"
      puts "src: #{src_url}"
      puts "alt: #{alt_text}"
    end
    puts "Loop counter is: #{c}"
    c += 1
    if found_counter > 9
      break
    end
end