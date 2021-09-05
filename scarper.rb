# frozen_string_literal: true

require_relative 'capybara_configuration'
require 'benchmark'

# News links pattern (Only news URL's contain publishing date in them)
NEWS_LINK_PATTERN = %r/\d{4}\/\d{2}\/\d{2}/.freeze
# News image url pattern (matches picture url in backgroung-image property)
PICTURE_URL_PATTERN = %r{https://.+\.jpeg}.freeze

browser = Capybara.current_session
browser.visit 'https://onliner.by'
puts 'Looking for news...'
news_links = browser.all('a').map { |a_tag| a_tag[:href] }.select { |res| res.match(NEWS_LINK_PATTERN) }.uniq
puts "Found #{news_links.count} news links"

File.open('news.csv', 'w') do |file|
  news_links.each do |link|
    puts "\nScarping #{link}"
    time = Benchmark.measure { browser.visit link }
    puts "  page loaded in #{time.real.round(2)}"
    name = browser.find('h1').text
    puts "  #{name}"
    text = browser.find('.news-text').all('p').map(&:text).join(' ')[0..200]
    puts "  #{text}"
    image = browser.find('.news-header__image').style('background-image')['background-image'].match(PICTURE_URL_PATTERN)
    puts "  #{image}"
    file.write("\"#{name}\",\"#{text}\",\"#{image}\"\n")
  end
end
