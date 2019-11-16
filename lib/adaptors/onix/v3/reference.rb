# frozen_string_literal: true

require_relative "reference/product"
require "forwardable"
require "byebug"

# This class only does one thing, but it does it very well
# It reads a thing called "doc", which it expects to be a Nokogiri
# XML reader, and it reads data from it.
# If it gets asked for anything much more complex, like stuff
# about the products in the XML, it will pass that on to
# a different class.
module Adaptors
  class Onix
    module V3
      class Reference
        extend Forwardable
        def initialize(doc)
          raise "Not expecting a #{doc.class}" unless
            doc.is_a? Nokogiri::XML::Document

          # Thanks for the thing called "doc"
          # We're going to save it in an instance variable also called "doc"
          @doc = doc
        end

        # If someone asks us for "products", we can find them in the XML with
        # this XPATH, but we're not going to try to interpret any of the
        # contents ourselves. We'll punt this to a different, specialised class.
        # We refer to it as "Product", and Ruby first looks for it
        # as Adaptors::Onix::V3::Reference::Product,
        # which is exactly where it is
        def products(publisher)
          titles = []
          doc.xpath("ONIXMessage/Product").map do |product_node|
            product = Product.new(product_node)
            next unless File.file?("images/covers/#{product.isbn}.jpg")
            # If you want to restrict the products by format, try something like the next line:
            # next unless ["Paperback","Hardback","Digital"].include? product.format
            next unless product&.publisher&.downcase&.include? publisher.downcase
            next if titles.include? product.title

            titles << product.title
            product
          end.flatten.compact
        end

        private

        # We have created an instance variable called @doc
        # This lets us write "doc" instead of "@doc" everywhere.
        # But it's our secret. Nobody outside of the class can see it.
        attr_reader :doc
      end
    end
  end
end
