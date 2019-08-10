require 'net/http'
require 'uri'
require 'byebug'

class FetchData
  def initialize
    retrieve_and_save_first_page
    all_pages
  end

  private

  def retrieve_and_save_first_page
    File.open("_data/raw_data_with_headers.json", "w") do |output|
      output.write(consonance_data(page: 1))
    end
  end

  def all_pages
    array = total_pages_count.times.map do |page|
      snipped_consonance_data(page: page + 1)
    end
    File.open("_data/raw_data.json", "w") do |output|
      output.write(array.to_json)
    end
  end

  def total_pages_count
    json_parse_raw_data_with_headers["total_pages"]
  end

  def snipped_consonance_data(page: nil)
    JSON.parse(consonance_data(page: page))["products"]
  end

  def json_parse_raw_data_with_headers
    JSON.parse(File.open("_data/raw_data_with_headers.json", "r").read)
  end

  def consonance_data(page: nil)
    uri = URI.parse("https://web.consonance.app/api/products.json?q[shops_id_eq]=1&page=#{page}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Token token=#{ENV['API_KEY']}"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    response.body
  end

  def sanitise(str)
    Sanitize.fragment(str, Sanitize::Config::RESTRICTED)
  end
end
