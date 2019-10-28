# frozen_string_literal: true

require_relative "../lib/adaptors/onix"
require_relative "../lib/adaptors/onix/v3"
require_relative "../lib/write_data"
require "nokogiri"
require "byebug"

RSpec.describe WriteData do
  subject do
    described_class.new(source)
  end

  let(:source) {Adaptors::Onix.new(publisher: "lup")}

  it "runs the code and returns nothing" do
    expect(subject.call).to eq(nil)
  end
end
