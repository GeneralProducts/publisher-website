# frozen_string_literal: true

require_relative "../lib/adaptors/onix/v3/reference/product"
require "nokogiri"
require "byebug"

RSpec.describe Adaptors::Onix::V3::Reference::Product do
  subject do
    described_class.new(product_node)
  end

  let(:product_node) do
    doc = Nokogiri::XML(File.open("fixtures/lup.xml"))
    doc.remove_namespaces!
    doc.xpath("ONIXMessage/Product").first
  end

  it "returns an ISBN" do
    expect(subject.isbn).to eq("9781789624151")
  end

  it "returns a format" do
    expect(subject.format).to eq("Digital")
  end

  it "returns the authorship" do
    expect(subject.authorship).to eq("Ian Kinane")
  end

  context "with multiple authors" do
    let(:product_node) do
      doc = Nokogiri::XML(File.open("fixtures/lup.xml"))
      doc.remove_namespaces!
      doc.xpath("ONIXMessage/Product")[6]
    end

    it "returns the authorship" do
      expect(subject.authorship).to eq("Glyn Morgan and Charul Palmer-Patel")
    end
  end

  it "returns the title" do
    expect(subject.title).to eq("Didactics and the Modern Robinsonade")
  end

  it "returns the subtitle" do
    expect(subject.subtitle).to eq("New Paradigms for Young Readers")
  end

  it "returns the series" do
    expect(subject.series).to eq("Liverpool English Texts and Studies")
  end

  it "returns the series number" do
    expect(subject.series_number).to eq("75")
  end

  it "returns the subjects" do
    expect(subject.subject).to eq(
      "Literary studies: fiction, novelists & prose writers, "\
      "Children’s & teenage literature studies: general, Europe, 20th century, "\
      "c 1900 to c 1999, Literary studies - fiction, novelists & prose writers, "\
      "Children's & teenage literature studies, Europe, 20th century, "\
      "LITERARY CRITICISM / European / English, Irish, Scottish, Welsh, "\
      "HISTORY / Modern / 20th Century, LITERARY CRITICISM / Children's & Young Adult Literature, "\
      "Robinson Crusoe;didactics;Robinsonade;postcolonial;island studies;childrens "\
      "literature;Daniel Defoe, English Literature"
    )
  end

  it "returns the cover URL" do
    expect(subject.front_cover_url).to eq(
      "https://bibliocloudimages.s3-eu-west-1.amazonaws.com/356/266948//_jpg_rgb_original.jpg"
    )
  end

  it "returns the GBP price" do
    expect(subject.gbp_price).to eq("78.00")
  end

  it "returns the USD price" do
    expect(subject.usd_price).to eq("120.00")
  end

  it "returns the page count" do
    expect(subject.page_count).to eq(nil)
  end

  context "with page counts" do
    let(:product_node) do
      doc = Nokogiri::XML(File.open("fixtures/lup.xml"))
      doc.remove_namespaces!
      doc.xpath("ONIXMessage/Product")[3]
    end

    it "returns the page count" do
      expect(subject.page_count).to eq("336")
    end
  end

  it "returns the pub date" do
    expect(subject.pub_date).to eq("Sep 06, 2019")
  end

  it "returns the pub_date in iso format" do
    expect(subject.pub_date_iso).to eq("20190906")
  end

  it "returns the blurb" do
    expect(subject.blurb).to eq(
      "This collection redresses both the gender and geopolitical biases "\
      "that have characterized most writings within the Robinsonade for young readers "\
      "since its inception, and includes chapters on little-known works of fiction "\
      "by female authors, as well as works from outside the mainstream of Anglo-American culture."
    )
  end

  it "returns reviews" do
    expect(subject.reviews).to eq(nil)
  end

  context "with reviews" do
    let(:product_node) do
      doc = Nokogiri::XML(File.open("fixtures/lup.xml"))
      doc.remove_namespaces!
      doc.xpath("ONIXMessage/Product")[3]
    end

    it "returns reviews" do
      expect(subject.reviews).to eq(<<~HTML.strip
        <p><h4>Reviews</h4>\n‘A major contribution to the literature on the US role in the Northern Ireland conflict. Elegantly written and factually accurate, it provides valuable new insights into some of the key aspects of American presidential involvement in the \"Troubles\". With penetrating analysis and ground-breaking research from sources on both sides of the Atlantic, this is a compelling book that will appeal to both academics and general readers.'<br>Professor Andrew Wilson, Loyola University Chicago</p>
      HTML
                                   )
    end
  end
end
