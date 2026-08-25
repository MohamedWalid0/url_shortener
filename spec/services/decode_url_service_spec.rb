require 'rails_helper'

RSpec.describe DecodeUrlService, type: :model do
  let!(:link) do
    Link.create!(original_url: "https://codesubmit.io/library/react", short_code: "GeAi9K")
  end

  it "returns the link for a known short code" do
    expect(described_class.call("http://your.domain/GeAi9K")).to eq(link)
  end

  it "ignores the host" do
    expect(described_class.call("http://localhost:3000/GeAi9K")).to eq(link)
  end

  it "handles a trailing slash" do
    expect(described_class.call("http://your.domain/GeAi9K/")).to eq(link)
  end

  it "returns nil for an unknown short code" do
    expect(described_class.call("http://your.domain/unknown")).to be_nil
  end

  it "returns nil when the url has no path" do
    expect(described_class.call("http://your.domain")).to be_nil
  end

  it "returns nil for a malformed url" do
    expect(described_class.call("http://your.domain/ bad path")).to be_nil
  end

  it "returns nil for nil input" do
    expect(described_class.call(nil)).to be_nil
  end
end
