# frozen_string_literal: true

require_relative "../lib/adaptors/onix/v3/reference"
require "nokogiri"
require "byebug"

RSpec.describe Adaptors::Onix::V3::Reference do
  subject do
    described_class.new(doc)
  end

  let(:doc) do
    doc = Nokogiri::XML(File.open("fixtures/snowbooks-pub.xml"))
    doc.remove_namespaces!
  end

  it "returns the products with an image" do
    expect(subject.products("").count).to eq(4)
  end

  context "with non-unique titles" do
    let(:doc) do
      doc = Nokogiri::XML(File.open("fixtures/multiple.xml"))
      doc.remove_namespaces!
    end

    it "returns the unique products with an image" do
      expect(subject.products("").count).to eq(4)
    end
  end

  context "with a publisher name" do
    let(:doc) do
      doc = Nokogiri::XML(File.open("fixtures/snowbooks-pub.xml"))
      doc.remove_namespaces!
    end

    it "returns the unique products with an image for the publisher" do
      expect(subject.products("Fauxbooks").count).to eq(1)
    end

    it "does a case insensitive filter" do
      expect(subject.products("fauxbooks").count).to eq(1)
    end

    it "does a partial string filter" do
      expect(subject.products("faux").count).to eq(1)
    end
  end
end
