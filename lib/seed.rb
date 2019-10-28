# frozen_string_literal: true

require_relative "adaptors/onix"
require_relative "adaptors/consonance"
require_relative "write_data"
require "optparse"

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: ruby lib/seed.rb --adaptor [adaptor] --publisher [publisher name]"
  opt.separator  ""
  opt.separator  "e.g. ruby lib/seed.rb --adaptor onix --publisher snowbooks"
  opt.separator  "     ruby lib/seed.rb -a onix -p snowbooks"
  opt.separator  "     ruby lib/seed.rb -a consonance"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-a", "--adaptor", "the adaptor you want to use to process your data: either onix or consonance") do |adaptor|
    options[:adaptor] = adaptor
  end

  opt.on("-p", "--publisher", "the publisher data you want to use") do |publisher|
    options[:publisher] = publisher
  end

  opt.on("-h", "--help", "help") do
  end

  opt.separator  ""
  opt.separator  "Adaptors"
  opt.separator  "     onix:       process an ONIX 3.0 file from the data directory"
  opt.separator  "     consonance: process JSON API from Consonance.app"
  opt.separator  "                 n.b. The consonance adaptor requires authentication"
  opt.separator  "                 via an API_KEY which you should store in ENV['API_KEY']."
  opt.separator  "                 and a SHOP_ID which you should store in ENV['SHOP_ID']."
  opt.separator  "                 Raise a ticket with support@consonance.app to get your key and ID."

  opt.separator  ""
  opt.separator  "Publishers"
  opt.separator  "     scribd          ONIX3 data from Scribd, courtesy of Consonance"
  opt.separator  "     facet           ONIX3 data from Facet, courtesy of Consonance"
  opt.separator  "     boldwood        ONIX3 data from Boldwood, courtesy of Consonance"
  opt.separator  "     taylor-francis  ONIX3 data from Taylor and Francis, courtesy of Nielsen"
end

opt_parser.parse!

if ARGV[0] == "onix" && %w[scribd facet taylor-francis boldwood lup].include?(ARGV[1])
  puts "\e[32mONIX is being processed for #{ARGV[1]}. Processed data will be put into _data/processed_books.json\e[0m"
  source = Adaptors::Onix.new(publisher: ARGV[1])
  WriteData.new(source).call

elsif ARGV[0] == "consonance"
  puts "\e[32mConsonance is being queried. Processed data will be put into _data/processed_books.json\e[0m"
  source = Adaptors::Consonance.new
  WriteData.new(source).call

else
  puts opt_parser
end
