# frozen_string_literal: true

require_relative 'product'

# This class only does one thing, but it does it very well
# It accepts a thing called "header_node", which it expects to be a Nokogiri
# XML node, and it reads data from it.
# If it gets asked for anything much more complex, like stuff
# about the products in the XML, it will punt that to a different class.
module Adaptors
  class Onix
    module V3
      class Reference
        class Header
          def initialize(header_node)
            raise "Not expecting a #{header_node.class}" unless
              header_node.is_a? Nokogiri::XML::Element

            # Thanks for the thing called "header_node"
            # We're going to save it in an instance variable
            # also called "header_node"
            @header_node = header_node
          end

          def sent_datetime
            header_node.at_xpath('SentDateTime')&.text
          end

          private

          # We have created an instance variable called @header_node
          # This lets us write "header_node" instead of "@header_node"
          # everywhere.
          # But it's our secret. Nobody outside of the class can see it.
          attr_reader :header_node
        end
      end
    end
  end
end
