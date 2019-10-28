# frozen_string_literal: true

require "forwardable"
require "byebug"
# This class only does one thing, but it does it very well
# It accepts a thing called "node", which it expects to be a Nokogiri
# XML node, and it reads data from it.
# If it gets asked for anything much more complex, like stuff
# about the products in the XML, it will punt that to
# a different class.
module Adaptors
  class Onix
    module V3
      class Reference
        class Product
          class Contributor
            extend Forwardable

            def initialize(node)
              raise "Not expecting a #{node.class}" unless
                node.is_a? Nokogiri::XML::Element

              # Thanks for the thing called "node"
              # We're going to save it in an instance variable
              # also called "node"
              @node = node
            end

            def sequence_number
              at_xpath("SequenceNumber")&.content&.to_i
            end

            def person_name
              at_xpath("PersonName")&.content
            end

            private

            def_delegators :node, :at_xpath

            attr_reader :node
          end
        end
      end
    end
  end
end
