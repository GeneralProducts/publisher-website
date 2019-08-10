require_relative 'convert_data'
require_relative 'convert_onix'
require_relative 'fetch_data'

src = ARGV[0]
publisher = ARGV[1]

if src == '--onix'
  ConvertOnix.new(publisher: publisher)
else
  FetchData.new
  ConvertData.new
end