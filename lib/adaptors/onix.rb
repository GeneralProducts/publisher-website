# frozen_string_literal: true

require "json"
require "lisbn"
require "sanitize"
require "byebug"
require "forwardable"
require_relative "onix/v3/reference"

ADAPTOR = {
  "http://ns.editeur.org/onix/3.0/reference" => Adaptors::Onix::V3::Reference
}.freeze

module Adaptors
  # An adaptor that gets the publisher's ONIX and processes it with Nokogiri
  class Onix
    extend Forwardable
    def initialize
      filename = "_data/onix.xml"

      # Use Nokogiri to open the ONIX file
      doc = Nokogiri::XML(File.open(filename))

      # Read the namespace of the file
      # This is found at the top on a line that is something like:
      # <ONIXMessage release="3.0"
      #   xmlns="http://ns.editeur.org/onix/3.0/reference">
      namespace = doc.namespaces["xmlns"]

      # Look up the namespace in our hash of adaptors, called ADAPTORS
      adaptor = ADAPTOR.fetch(namespace)

      # Now we know which class to read this kind of file with.
      # We use `new` to get a new instance of that class, passing our
      # Nokogiri document to it.
      @reader = adaptor.new(doc.remove_namespaces!)
    end

    # We have created an instance variable called @reader
    # This lets us write "reader" instead of "@reader" everywhere.
    attr_accessor :reader

    # If we ask this class for the products, it passes the request
    # on to @reader.
    def_delegators :reader, :products
  end
end
