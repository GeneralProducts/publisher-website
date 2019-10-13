require 'json'
require 'lisbn'
require 'sanitize'
require 'byebug'
require_relative "onix/v3/reference"
require 'forwardable'

module Adaptors
  class Onix
    extend Forwardable
    def initialize(publisher:)
      # Work out where the publisher's ONIX file is expected to be
      filename  = "_data/#{publisher}.xml"

      # Use Nokogiri to open the publisher's ONIX file
      doc = Nokogiri::XML(File.open(filename))

      # Read the namespace of the file
      # This is found at the top on a line that is something like:
      #   <ONIXMessage release="3.0" xmlns="http://ns.editeur.org/onix/3.0/reference">
      namespace = doc.namespaces["xmlns"]

      # Lookup up the namespace in our hash of adaptors, called ADAPTORS
      adaptor = ADAPTOR.fetch(namespace)

      # Now we know which class to read this kind of file with.
      # We use `new` to get a new instance of that class, passing our
      # Nokogiri document to it.
      @reader = adaptor.new(doc.remove_namespaces!)
    end

    # We have created an instance variable called @reader
    # This lets us write "reader" instead of "@reader" everywhere.
    attr_accessor :reader

    private

    ADAPTOR = {
      "http://ns.editeur.org/onix/3.0/reference" => Adaptors::Onix::V3::Reference
    }

    # If we ask this class for the products, it just passes the request
    # on to @reader.
    def_delegators :reader, :products

    def parsed_raw_data
      @_parsed_raw_data ||= Nokogiri::XML(File.open(filename)).remove_namespaces!
    end

    TITLE = 'DescriptiveDetail/TitleDetail/TitleElement/TitleWithoutPrefix'.freeze
    IMAGE_URL = 'CollateralDetail/SupportingResource/ResourceVersion/ResourceLink'.freeze
    ISBN13 = "ProductIdentifier[ProductIDType='15']/IDValue".freeze

    def processed_data
      parsed_raw_data.xpath('/ONIXMessage/Product').flat_map do |product_node|
        next unless product_node.at_xpath('CollateralDetail/SupportingResource')
        {
          'title'                   => sanitise(product_node.at_xpath(TITLE).text),
          'image_path'              => product_node.at_xpath(IMAGE_URL).text,
          'isbn'                    => product_node.at_xpath(ISBN13).text,
          "amz_uk_url"            => "http://www.amazon.co.uk/gp/product/#{isbn10(product_node)}",
          "amz_us_url"            => "http://www.amazon.com/gp/product/#{isbn10(product_node)}",
          "amz_ca_url"            => "http://www.amazon.ca/gp/product/#{isbn10(product_node)}",
          "amz_de_url"            => "http://www.amazon.de/gp/product/#{isbn10(product_node)}",
          "amz_br_url"            => "http://www.amazon.com.br/gp/product/#{isbn10(product_node)}",
          "amz_mx_url"            => "http://www.amazon.com.mx/gp/product/#{isbn10(product_node)}",
          "amz_fr_url"            => "http://www.amazon.fr/gp/product/#{isbn10(product_node)}",
          "amz_es_url"            => "http://www.amazon.es/gp/product/#{isbn10(product_node)}",
          "amz_jp_url"            => "http://www.amazon.co.jp/gp/product/#{isbn10(product_node)}",
          "amz_in_url"            => "http://www.amazon.in/gp/product/#{isbn10(product_node)}",
          "kobo_url"              => "https://store.kobobooks.com/search?Query=#{isbn13(product_node)}",
          "infini-beam_url"       => "http://www.infibeam.com/search?q=#{isbn13(product_node)}",
          "google_play_url"       => "https://play.google.com/store/search?q=#{isbn13(product_node)}",
          "hive_url"              => "http://www.hive.co.uk/Search/Keyword?keyword=#{isbn13(product_node)}&productType=0",
          "booktopia_url"         => "http://www.booktopia.com.au/search.ep?keywords=#{isbn13(product_node)}&productType=917504",
          "barnes_and_noble_url"  => "http://www.barnesandnoble.com/s/#{isbn13(product_node)}",
          "worldcat_url"          => "http://www.worldcat.org/search?q=#{isbn13(product_node)}",
          "books_a_million_url"   => "http://www.booksamillion.com/search?query=#{isbn13(product_node)}&where=All",
          "book_finder_url"       => "http://www.bookfinder.com/search/?author=&title=&lang=en&isbn=#{isbn13(product_node)}&new=1&used=1&ebooks=1&mode=basic&st=sr&ac=qr",
          "wordery_url"           => "https://wordery.com/search?term=#{isbn13(product_node)}",
          "waterstones_url"       => "https://www.waterstones.com/index/search/?term=#{isbn13(product_node)}",
          "foyles_url"            => "http://www.foyles.co.uk/all?term=#{isbn13(product_node)}",
          "book_depository_url"   => "http://www.bookdepository.com/book/#{isbn13(product_node)}",
          "wh_smith_url"          => "http://www.whsmith.co.uk/search/go?af=&w=#{isbn13(product_node)}",
          "blackwells_url"        => "http://bookshop.blackwell.co.uk/jsp/welcome.jsp?action=search&type=isbn&term=#{isbn13(product_node)}",
          "oxfam_url"             => "http://www.oxfam.org.uk/search-results?q=#{isbn13(product_node)};show_all=ogb_mixed",
          # "subtitle"              => sanitise(product["subtitle"]),
          # "author"                => sanitise(product["authorship"]),
          # "subject"               => product["main_subject_id"],
          # "series"                => product["series_ids"],
          # "pub_date"              => product["pub_date"],
          # "page_count"            => product["extents"]["page_count"],
          # "usd_price"             => (sanitise(product["prices"].find {|x| x["currency_code"] == "USD"}["price_amount"]) rescue nil),
          # "gbp_price"             => (sanitise(product["prices"].find {|x| x["currency_code"] == "GBP"}["price_amount"]) rescue nil),
          # "measurements"          => product["measurements"]["product_dimensions_mm"],
          # "blurb"                 => (sanitise(product["marketingtexts"].find {|x| x["code"] == "01"}["external_text"]) rescue nil),
          # "reviews"               => (sanitise(product["marketingtexts"].find {|x| x["code"] == "08"}["external_text"]) rescue nil),
          # "isbns"                 => (product["all_related_products"].find_all {|x| x["relation_code"] == "06"}.map {|x| x["isbn"] unless x["isbn"] == "No ISBN" }.flatten.join('<br/>') rescue nil)
        }
      end.compact
    end

    def export
      File.open('_data/processed_books.json', 'w') do |output|
        output.write(processed_data.to_json)
      end
    end

    def sanitise(str)
      Sanitize.fragment(str, Sanitize::Config::RESTRICTED)
    end

    def isbn10(product_node)
      @isbn10 ||= Lisbn.new(product_node.at_xpath(ISBN13).text).isbn10
    end

    def isbn13(product_node)
      @isbn13 ||= Lisbn.new(product_node.at_xpath(ISBN13).text).isbn13
    end
  end
end