# frozen_string_literal: true

require "forwardable"
require "byebug"
require_relative "product/contributor"

module Adaptors
  class Onix
    module V3
      # This class only does one thing, but it does it very well
      # It accepts a thing called "product_node", which it expects to be a Nokogiri
      # XML node, and it reads data from it.
      # If it gets asked for anything much more complex, like information
      # about the products in the XML, it will punt that to a different class.
      class Reference
        class Product # rubocop:disable Metrics/ClassLength
          extend Forwardable

          def initialize(product_node)
            raise "Not expecting a #{product_node.class}" unless product_node.is_a? Nokogiri::XML::Element

            # Thanks for the thing called "product_node"
            # We're going to save it in an instance variable also called "product_node"
            @product_node = product_node
          end

          def isbn
            at_xpath("ProductIdentifier[ProductIDType=15]/IDValue").content
          end

          def publisher
            at_xpath("PublishingDetail/Publisher[PublishingRole=01]/PublisherName")&.content
          end

          def format
            form = at_xpath("DescriptiveDetail/ProductForm").content
            case form
            when "BB"
              "Hardback"
            when "BC"
              "Paperback"
            when "EA"
              "Digital"
            else
              "Unknown"
            end
          end

          def authorship
            names = contributors.map(&:person_name)

            case names.length
            when 0
              ""
            when 1
              names[0]
            when 2
              "#{names[0]} and #{names[1]}"
            else
              "#{names[0...-1].join(', ')}, and #{names[-1]}"
            end
          end

          def title
            [
              title_element.at_xpath("TitlePrefix")&.content,
              title_element.at_xpath("TitleWithoutPrefix")&.content
            ].compact.join(" ")
          end

          def subtitle
            title_element.at_xpath("Subtitle")&.content
          end

          def series
            at_xpath("DescriptiveDetail/Collection[CollectionType=10]/TitleDetail/TitleElement/TitleWithoutPrefix")&.content
          end

          def series_number
            at_xpath("DescriptiveDetail/Collection[CollectionType=10]/CollectionSequence/CollectionSequenceNumber")&.content
          end

          def subject
            xpath("DescriptiveDetail/Subject").map do |subject|
              next if subject.xpath("SubjectSchemeIdentifier=20")

              subject.at_xpath("SubjectHeadingText")
            end.compact.flatten.join(", ")
          end

          def front_cover_url
            collateral_detail.at_xpath("SupportingResource[ResourceContentType=01]/ResourceVersion/ResourceLink")&.content
          end

          def gbp_price
            price(currency_code: "GBP")
          end

          def usd_price
            price(currency_code: "USD")
          end

          def page_count
            at_xpath("DescriptiveDetail/Extent[ExtentType=01]/ExtentValue")&.content ||
              at_xpath("DescriptiveDetail/Extent[ExtentType=00]/ExtentValue")&.content
          end

          def pub_date
            date_string = publishing_detail.at_xpath("PublishingDate/Date")&.content
            return unless date_string

            begin
              Date.parse(date_string).strftime("%b %d, %Y")
            rescue # rubocop:disable Style/RescueStandardError
              puts "ONIX for product with ISBN #{isbn} contains invalid pub date: #{date_string}"
            end
          end

          def pub_date_iso
            publishing_detail.at_xpath("PublishingDate/Date")&.content
          end

          def blurb
            collateral_detail.at_xpath("TextContent[TextType=02]/Text")&.content ||
              collateral_detail.at_xpath("TextContent[TextType=03]/Text")&.content
          end

          def reviews
            collateral_detail.at_xpath("TextContent[TextType=06]/Text")&.content
          end

          private

          def contributors
            xpath("DescriptiveDetail/Contributor").map do |contributor|
              Contributor.new(contributor)
            end.sort_by(&:sequence_number)
          end

          def price(currency_code: nil)
            at_xpath("ProductSupply/SupplyDetail/Price[CurrencyCode='#{currency_code}']/PriceAmount")&.content
          end

          def title_element
            @_title_element ||= at_xpath("DescriptiveDetail/TitleDetail[TitleType=01]/TitleElement[TitleElementLevel=01]")
          end

          def collateral_detail
            xpath("CollateralDetail")
          end

          def publishing_detail
            xpath("PublishingDetail")
          end

          # How boring to keep typing product_node.at_xpath and product_node.xpath.
          # This lets us type at_xpath, and it gets sent to the right place
          def_delegators :product_node, :at_xpath, :xpath

          # We have created an instance variable called @product_node
          # This lets us write "product_node" instead of "@product_node" everywhere.
          # But it's our secret. Nobody outside of the class can see it.
          attr_reader :product_node
        end
      end
    end
  end
end
