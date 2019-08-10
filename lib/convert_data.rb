require 'json'
require 'lisbn'
require 'sanitize'
require 'byebug'

class ConvertData
  def initialize
    export
    delete_old_files
  end

  private

  def parsed_raw_data
    JSON.parse(File.open("_data/raw_data.json", "r").read)
  end

  def processed_data
    parsed_raw_data.map do |group|
      group.map do |product|
        {
          "title"                 => sanitise(product["full_title"]),
          "isbn"                  => product["isbn"],
          "amz_uk_url"            => "http://www.amazon.co.uk/gp/product/#{isbn10(product)}",
          "amz_us_url"            => "http://www.amazon.com/gp/product/#{isbn10(product)}",
          "amz_ca_url"            => "http://www.amazon.ca/gp/product/#{isbn10(product)}",
          "amz_de_url"            => "http://www.amazon.de/gp/product/#{isbn10(product)}",
          "amz_br_url"            => "http://www.amazon.com.br/gp/product/#{isbn10(product)}",
          "amz_mx_url"            => "http://www.amazon.com.mx/gp/product/#{isbn10(product)}",
          "amz_fr_url"            => "http://www.amazon.fr/gp/product/#{isbn10(product)}",
          "amz_es_url"            => "http://www.amazon.es/gp/product/#{isbn10(product)}",
          "amz_jp_url"            => "http://www.amazon.co.jp/gp/product/#{isbn10(product)}",
          "amz_in_url"            => "http://www.amazon.in/gp/product/#{isbn10(product)}",
          "kobo_url"              => "https://store.kobobooks.com/search?Query=#{isbn13(product)}",
          "infini-beam_url"       => "http://www.infibeam.com/search?q=#{isbn13(product)}",
          "google_play_url"       => "https://play.google.com/store/search?q=#{isbn13(product)}",
          "hive_url"              => "http://www.hive.co.uk/Search/Keyword?keyword=#{isbn13(product)}&productType=0",
          "booktopia_url"         => "http://www.booktopia.com.au/search.ep?keywords=#{isbn13(product)}&productType=917504",
          "barnes_and_noble_url"  => "http://www.barnesandnoble.com/s/#{isbn13(product)}",
          "worldcat_url"          => "http://www.worldcat.org/search?q=#{isbn13(product)}",
          "books_a_million_url"   => "http://www.booksamillion.com/search?query=#{isbn13(product)}&where=All",
          "book_finder_url"       => "http://www.bookfinder.com/search/?author=&title=&lang=en&isbn=#{isbn13(product)}&new=1&used=1&ebooks=1&mode=basic&st=sr&ac=qr",
          "wordery_url"           => "https://wordery.com/search?term=#{isbn13(product)}",
          "waterstones_url"       => "https://www.waterstones.com/index/search/?term=#{isbn13(product)}",
          "foyles_url"            => "http://www.foyles.co.uk/all?term=#{isbn13(product)}",
          "book_depository_url"   => "http://www.bookdepository.com/book/#{isbn13(product)}",
          "wh_smith_url"          => "http://www.whsmith.co.uk/search/go?af=&w=#{isbn13(product)}",
          "blackwells_url"        => "http://bookshop.blackwell.co.uk/jsp/welcome.jsp?action=search&type=isbn&term=#{isbn13(product)}",
          "oxfam_url"             => "http://www.oxfam.org.uk/search-results?q=#{isbn13(product)};show_all=ogb_mixed",
          "subtitle"              => sanitise(product["subtitle"]),
          "image_path"            => ((product["supportingresources"][0]["style_urls"].find {|x| x['style'] == 'jpg_rgb_0650h'}["url"]) if product["supportingresources"][0]),
          "author"                => sanitise(product["authorship"]),
          "subject"               => product["main_subject_id"],
          "series"                => product["series_ids"],
          "pub_date"              => product["pub_date"],
          "page_count"            => product["extents"]["page_count"],
          "usd_price"             => (sanitise(product["prices"].find {|x| x["currency_code"] == "USD"}["price_amount"]) rescue nil),
          "gbp_price"             => (sanitise(product["prices"].find {|x| x["currency_code"] == "GBP"}["price_amount"]) rescue nil),
          "measurements"          => product["measurements"]["product_dimensions_mm"],
          "blurb"                 => (sanitise(product["marketingtexts"].find {|x| x["code"] == "01"}["external_text"]) rescue nil),
          "reviews"               => (sanitise(product["marketingtexts"].find {|x| x["code"] == "08"}["external_text"]) rescue nil),
          "isbns"                 => (product["all_related_products"].find_all {|x| x["relation_code"] == "06"}.map {|x| x["isbn"] unless x["isbn"] == "No ISBN" }.flatten.join('<br/>') rescue nil)
        }
      end
    end.flatten
  end

  def export
    File.open("_data/processed_books.json", "w") do |output|
      output.write(processed_data.to_json)
    end
  end

  def sanitise(str)
    Sanitize.fragment(str, Sanitize::Config::RESTRICTED)
  end

  def delete_old_files
    File.delete("_data/raw_data_with_headers.json") if File.exists?("_data/raw_data_with_headers.json")
    File.delete("_data/raw_data.json") if File.exists?("_data/raw_data.json")
  end

  def isbn10(product)
    Lisbn.new(product["isbn"]).isbn10
  end

  def isbn13(product)
    Lisbn.new(product["isbn"]).isbn13
  end
end
