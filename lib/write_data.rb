# frozen_string_literal: true

require "json"
require "lisbn"
require "sanitize"
require "byebug"
require "open-uri"

class WriteData
  def initialize(source, publisher)
    @source = source
    @publisher = publisher
  end

  def call
    export
    covers
    delete_old_files
  end

  private

  attr_reader :source, :publisher

  def processed_data
    @_processed_data ||= source.products(publisher).map do |product|
      {
        "title" => product.title,
        "isbn" => product.isbn,
        "amz_uk_url" => "http://www.amazon.co.uk/gp/product/#{isbn10(product)}",
        "amz_us_url" => "http://www.amazon.com/gp/product/#{isbn10(product)}",
        "amz_ca_url" => "http://www.amazon.ca/gp/product/#{isbn10(product)}",
        "amz_de_url" => "http://www.amazon.de/gp/product/#{isbn10(product)}",
        "amz_br_url" => "http://www.amazon.com.br/gp/product/#{isbn10(product)}",
        "amz_mx_url" => "http://www.amazon.com.mx/gp/product/#{isbn10(product)}",
        "amz_fr_url" => "http://www.amazon.fr/gp/product/#{isbn10(product)}",
        "amz_es_url" => "http://www.amazon.es/gp/product/#{isbn10(product)}",
        "amz_jp_url" => "http://www.amazon.co.jp/gp/product/#{isbn10(product)}",
        "amz_in_url" => "http://www.amazon.in/gp/product/#{isbn10(product)}",
        "kobo_url" => "https://store.kobobooks.com/search?Query=#{isbn13(product)}",
        "infini-beam_url" => "http://www.infibeam.com/search?q=#{isbn13(product)}",
        "google_play_url" => "https://play.google.com/store/search?q=#{isbn13(product)}",
        "hive_url" => "http://www.hive.co.uk/Search/Keyword?keyword=#{isbn13(product)}&productType=0",
        "booktopia_url" => "http://www.booktopia.com.au/search.ep?keywords=#{isbn13(product)}&productType=917504",
        "barnes_and_noble_url" => "http://www.barnesandnoble.com/s/#{isbn13(product)}",
        "worldcat_url" => "http://www.worldcat.org/search?q=#{isbn13(product)}",
        "books_a_million_url" => "http://www.booksamillion.com/search?query=#{isbn13(product)}&where=All",
        "book_finder_url" => "http://www.bookfinder.com/search/?author=&title=&lang=en&isbn=#{isbn13(product)}&new=1&used=1&ebooks=1&mode=basic&st=sr&ac=qr",
        "wordery_url" => "https://wordery.com/search?term=#{isbn13(product)}",
        "waterstones_url" => "https://www.waterstones.com/index/search/?term=#{isbn13(product)}",
        "foyles_url" => "http://www.foyles.co.uk/all?term=#{isbn13(product)}",
        "book_depository_url" => "http://www.bookdepository.com/book/#{isbn13(product)}",
        "wh_smith_url" => "http://www.whsmith.co.uk/search/go?af=&w=#{isbn13(product)}",
        "blackwells_url" => "http://bookshop.blackwell.co.uk/jsp/welcome.jsp?action=search&type=isbn&term=#{isbn13(product)}",
        "oxfam_url" => "http://www.oxfam.org.uk/search-results?q=#{isbn13(product)};show_all=ogb_mixed",
        "subtitle" => sanitise(product.subtitle),
        "image_path" => product.front_cover_url,
        "author" => sanitise(product.authorship),
        "blurb" => sanitise(product.blurb),
        "reviews" => sanitise(product.reviews),
        "subject" => product.subject,
        "series" => product.series,
        "series_number" => product.series_number,
        "pub_date" => product.pub_date,
        "pub_date_iso" => product.pub_date_iso,
        "page_count" => product.page_count,
        "usd_price" => product.usd_price,
        "gbp_price" => product.gbp_price,
        "format" => product.format
      }
    end
  end

  def export
    File.open("_data/processed_books.json", "w") do |output|
      output.write(processed_data.to_json)
    end
  end

  def covers
    processed_data.each do |product_output|
      url  = product_output["image_path"]
      isbn = product_output["isbn"]
      next unless url && isbn

      filename = "images/covers/#{isbn}.jpg"
      next if File.exist?(filename)

      open(filename, "wb") do |file|
        file << open(url).read
      end
    end
  rescue StandardError => e
    puts "Error in cover processing: #{e}."
  end

  def sanitise(str)
    Sanitize.fragment(str, Sanitize::Config::RESTRICTED).encode(Encoding.find("ASCII"), encoding_options)
  end

  def encoding_options
    {
      invalid: :replace, # Replace invalid byte sequences
      undef: :replace, # Replace anything not defined in ASCII
      replace: "", # Use a blank for those replacements
      universal_newline: true # Always break lines with \n
    }
  end

  def delete_old_files
    File.delete("_data/raw_data_with_headers.json") if
      File.exist?("_data/raw_data_with_headers.json")
    File.delete("_data/raw_data.json") if File.exist?("_data/raw_data.json")
  end

  def isbn10(product)
    Lisbn.new(product.isbn).isbn10
  end

  def isbn13(product)
    Lisbn.new(product.isbn).isbn13
  end
end
