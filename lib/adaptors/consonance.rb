# frozen_string_literal: true

require "net/http"
require "uri"
require "byebug"
require "ostruct"

module Adaptors
  # An adaptor that gets JSON data from Consonance and processes it
  class Consonance
    def initialize
      retrieve_and_save_first_page
      all_pages
    end

    def products
      processed_data.map do |hash|
        OpenStruct.new(hash)
      end
    end

    private

    def parsed_raw_data
      JSON.parse(File.open("_data/raw_data.json", "r").read)
    rescue StandardError => e
      puts "\e[31mError: #{e}.\e[0m"
    end

    def processed_data
      parsed_raw_data.map do |group|
        group.map do |product_hash|
          product = OpenStruct.new(product_hash)

          {
            "title" => product.full_title,
            "isbn" => product.isbn,
            "subtitle" => product.subtitle,
            "front_cover_url" => ((product.supportingresources[0]["style_urls"].find { |x| x["style"] == "jpg_rgb_0650h" }["url"]) if product.supportingresources[0]),
            "author" => product.authorship,
            "subject" => product.main_subject_id,
            "series" => product.series_ids,
            "pub_date" => product.pub_date,
            "page_count" => product.extents["page_count"],
            "usd_price" => price_amount(product, "USD"),
            "gbp_price" => price_amount(product, "GBP"),
            "measurements" => (product.measurements["product_dimensions_mm"] if product.measurements),
            "blurb" => text(product, "01"),
            "reviews" => text(product, "08"),
            "isbns" => product.all_related_products.find_all { |x| x["relation_code"] == "06" }.map { |x| x["isbn"] unless x["isbn"] == "No ISBN" }.flatten.join("<br/>")
          }
        end
      end.flatten
    end

    def text(product, code)
      text_record = product.marketingtexts.find do |x|
        x["code"] == code
      end
      return unless text_record

      text_record["external_text"]
    end

    def price_amount(product, currency)
      price = product.prices.find do |x|
        x["currency_code"] == currency
      end
      return unless price

      price["price_amount"]
    end

    def retrieve_and_save_first_page
      File.open("_data/raw_data_with_headers.json", "w") do |output|
        output.write(consonance_data(page: 1))
      end
    end

    def all_pages
      return unless total_pages_count

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
      uri = URI.parse(
        "https://web.consonance.app/api/products.json?q[shops_id_eq]=#{ENV['SHOP_ID']}&page=#{page}"
      )
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Token token=#{ENV['API_KEY']}"
      req_options = { use_ssl: uri.scheme == "https" }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      response.body
    end
  end
end
