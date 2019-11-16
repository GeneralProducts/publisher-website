# frozen_string_literal: true

require_relative "../lib/adaptors/onix/v3/reference/product"
require "nokogiri"
require "byebug"
require "date"

RSpec.describe Adaptors::Onix::V3::Reference::Product do
  subject do
    described_class.new(product_node)
  end

  let(:product_node) do
    doc = Nokogiri::XML(File.open("fixtures/snowbooks.xml"))
    doc.remove_namespaces!
    doc.xpath("ONIXMessage/Product").first
  end

  it "returns an ISBN" do
    expect(subject.isbn).to eq("9781911390220")
  end

  it "returns a format" do
    expect(subject.format).to eq("Paperback")
  end

  it "returns the authorship" do
    expect(subject.authorship).to eq("Bryan Wigmore")
  end

  context "with multiple authors" do
    let(:product_node) do
      doc = Nokogiri::XML(File.open("fixtures/snowbooks.xml"))
      doc.remove_namespaces!
      doc.xpath("ONIXMessage/Product")[6]
    end

    it "returns the authorship" do
      expect(subject.authorship).to eq("Jonathan Green and Kev Crossley")
    end
  end

  it "returns the title" do
    expect(subject.title).to eq("The Goddess Project")
  end

  it "returns the subtitle" do
    expect(subject.subtitle).to eq(nil)
  end

  context "with subtitle" do
    let(:product_node) do
      doc = Nokogiri::XML(File.open("fixtures/snowbooks.xml"))
      doc.remove_namespaces!
      doc.xpath("ONIXMessage/Product")[6]
    end

    it "returns the subtitle" do
      expect(subject.subtitle).to eq("Here Be Monsters!")
    end
  end

  it "returns the series" do
    expect(subject.series).to eq("Fire Stealers")
  end

  it "returns the series number" do
    expect(subject.series_number).to eq("1")
  end

  it "returns the subjects" do
    expect(subject.subject).to eq(
      "Fantasy, Science fiction: steampunk, Scuba diving, Mysticism, "\
      "magic & occult interests, Shamanism, paganism & druidry, Victorian "\
      "period (1837–1901), Fantasy, FICTION / Fantasy / General, SF / Fantasy"
    )
  end

  it "returns the cover URL" do
    expect(subject.front_cover_url).to eq(
      "https://bibliocloudimages.s3-eu-west-1.amazonaws.com/1/250806//_jpg_rgb_original.jpg"
    )
  end

  it "returns the GBP price" do
    expect(subject.gbp_price).to eq("8.99")
  end

  it "returns the USD price" do
    expect(subject.usd_price).to eq("15.95")
  end

  it "returns the page count" do
    expect(subject.page_count).to eq(nil)
  end

  context "with page counts" do
    let(:product_node) do
      doc = Nokogiri::XML(File.open("fixtures/snowbooks.xml"))
      doc.remove_namespaces!
      doc.xpath("ONIXMessage/Product")[2]
    end

    it "returns the page count" do
      expect(subject.page_count).to eq("360")
    end
  end

  it "returns the pub date" do
    expect(subject.pub_date).to eq("Jan 02, 2017")
  end

  it "returns the pub_date in iso format" do
    expect(subject.pub_date_iso).to eq("20170102")
  end

  it "returns the blurb" do
    expect(subject.blurb).to eq(<<~HTML.strip
      <p>‘Ancient terror, modern error, future era.’ Otter shook himself. ‘Mean much to you?’</p><p>Two years after being washed up on a remote beach, freedivers Orc and Cass still have no idea who they are or where they came from. Worst of all, they feel like lovers but look like brother and sister, and must repress their instincts for fear of committing a terrible mistake.</p><p>Now at last they’ve tracked down a psychic artefact powerful enough to restore their memories. But others also seek its forbidden magic. To reach it, deep within a sunken ruin, they must flirt with a ruthless occult conspiracy, one intent on summoning an ancient goddess to destroy the dreadnoughts of the Empyreal fleet.</p><p>The depths of the sea, of the past, of the world’s collective mind: down there are truths, but also madness and despair. And a power that will plunge the world back to a new dark age, if it can’t be stopped.</p>
    HTML
                               )
  end

  it "returns reviews" do
    expect(subject.reviews).to eq(<<~HTML.strip
      <p>"In the end, it's one of my best reads so far this year." -- Brian G. Turner, <i>SFF Chronicles</i></p>
    HTML
                                 )
  end

  context "without reviews" do
    let(:product_node) do
      doc = Nokogiri::XML(File.open("fixtures/snowbooks.xml"))
      doc.remove_namespaces!
      doc.xpath("ONIXMessage/Product")[2]
    end

    it "returns reviews" do
      expect(subject.reviews).to eq(nil)
    end
  end
end
