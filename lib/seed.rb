require_relative 'convert_data'
require_relative 'adaptors/onix'
require_relative 'fetch_data'
require_relative 'write_data'

src = ARGV[0]
publisher = ARGV[1]

if src == '--onix'
  source = Adaptors::Onix.new(publisher: publisher)
else
  FetchData.new
  ConvertData.new
end

WriteData.new(source).call
