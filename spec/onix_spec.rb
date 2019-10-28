# frozen_string_literal: true

require_relative "../lib/adaptors/onix/v3/reference"
require "nokogiri"
require "byebug"

RSpec.describe Adaptors::Onix do
  subject do
    described_class.new(publisher: "lup")
  end

  it "produces the correct class" do
    expect(subject.class).to eq(Adaptors::Onix)
  end

  it "produces a reader to the correct adaptor" do
    expect(subject.reader.class).to eq(Adaptors::Onix::V3::Reference)
  end

  it "passes a call to products on correctly to Reference" do
    expect(subject.products.count).to eq(8)
  end
end
