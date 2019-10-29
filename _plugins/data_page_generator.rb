# frozen_string_literal: true

# Generate pages from individual records in yml files
# (c) 2014-2016 Adolfo Villafiorita
# Distributed under the conditions of the MIT License
# Adapted for Day of Code by Emma Barnes 2019

module Jekyll
  module Sanitizer
    def sanitize_filename(name)
      return name.to_s if name.is_a? Integer

      name.gsub(/[^a-z._0-9 -]/i, "").tr(".", "-").gsub(/(\s+)/, "-").downcase
    end
  end

  class DataPage < Page
    include Sanitizer

    def initialize(data, site)
      @site = site
      base = site.source
      filename = sanitize_filename(data["title"]).to_s
      @dir = "books/" + filename + "/"

      process('index.html')
      read_yaml(File.join(base, '_layouts'), 'book_template.html')
      self.data.merge!(data)
    end
  end

  class DataPagesGenerator < Generator
    safe true

    def generate(site)
      site.data["processed_books"].each do |page_data|
        site.pages << DataPage.new(page_data, site)
      end
    end
  end

  module DataPageLinkGenerator
    include Sanitizer
    def datapage_url(input)
      "/books/#{sanitize_filename(input)}/"
    end
  end
end

Liquid::Template.register_filter(Jekyll::DataPageLinkGenerator)
