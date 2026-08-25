require 'rails_helper'

RSpec.describe EncodeUrlService, type: :model do
  let(:url) { "https://codesubmit.io/library/react" }

  def sha1_code(value, length = described_class::CODE_LENGTH)
    Digest::SHA1.hexdigest(value).first(length)
  end

  it "returns the persisted link with the sha1 derived short code" do
    link = described_class.call(url)

    expect(link).to be_persisted
    expect(link.short_code).to eq(sha1_code(url))
    expect(link.short_code.length).to eq(described_class::CODE_LENGTH)
    expect(link.original_url).to eq(url)
  end

  it "returns the same link for the same url without creating a second one" do
    first = described_class.call(url)

    expect { expect(described_class.call(url)).to eq(first) }.not_to change(Link, :count)
  end

  it "ignores a trailing slash so both spellings share one link" do
    bare = described_class.call("https://wasladm.net")

    expect { expect(described_class.call("https://wasladm.net/")).to eq(bare) }.not_to change(Link, :count)
    expect(bare.original_url).to eq("https://wasladm.net")
    expect(bare.short_code).to eq(sha1_code("https://wasladm.net"))
  end

  it "ignores trailing slashes and surrounding whitespace on paths too" do
    link = described_class.call("https://wasladm.net/docs")

    expect(described_class.call("https://wasladm.net/docs/")).to eq(link)
    expect(described_class.call("  https://wasladm.net/docs  ")).to eq(link)
    expect(Link.count).to eq(1)
  end

  it "collapses the root slash in front of a query without dropping the query" do
    link = described_class.call("https://wasladm.net/?a=1")

    expect(link.original_url).to eq("https://wasladm.net?a=1")
    expect(described_class.call("https://wasladm.net?a=1")).to eq(link)
    expect(described_class.call("https://wasladm.net")).not_to eq(link)
  end

  it "returns nil for blank input" do
    expect(described_class.call(nil)).to be_nil
    expect(described_class.call("")).to be_nil
    expect(described_class.call("   ")).to be_nil
    expect(described_class.call("/")).to be_nil
  end

  it "round trips through DecodeUrlService" do
    link = described_class.call(url)

    expect(DecodeUrlService.call("http://your.domain/#{link.short_code}")).to eq(link)
  end

  context "when another url already holds the unsalted code" do
    let!(:squatter) { Link.create!(short_code: sha1_code(url), original_url: "https://example.com/other") }

    it "falls through to the salted code and leaves the existing link intact" do
      link = described_class.call(url)

      expect(link.short_code).not_to eq(squatter.short_code)
      expect(link.short_code).to eq(sha1_code("#{url}1"))
      expect(squatter.reload.original_url).to eq("https://example.com/other")
    end

    it "stays idempotent and keeps both codes resolvable" do
      link = described_class.call(url)

      expect(described_class.call(url)).to eq(link)
      expect(DecodeUrlService.call("http://your.domain/#{link.short_code}")).to eq(link)
      expect(DecodeUrlService.call("http://your.domain/#{squatter.short_code}")).to eq(squatter)
    end
  end

  it "survives a row appearing at the target code before the insert" do
    existing = Link.create!(short_code: sha1_code(url), original_url: url)

    expect { expect(described_class.call(url)).to eq(existing) }.not_to change(Link, :count)
  end

  it "gives up after MAX_ATTEMPTS when every candidate code is taken" do
    described_class::MAX_ATTEMPTS.times do |attempt|
      key = attempt.zero? ? url : "#{url}#{attempt}"
      Link.create!(short_code: sha1_code(key), original_url: "https://example.com/taken/#{attempt}")
    end

    expect(described_class.call(url)).to be_nil
  end
end
