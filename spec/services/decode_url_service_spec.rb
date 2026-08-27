require 'rails_helper'

RSpec.describe DecodeUrlService, type: :model do
  let(:host) { described_class::HOST }

  let!(:link) do
    Link.create!(original_url: "https://codesubmit.io/library/react", short_code: "GeAi9K")
  end

  it "returns the link for a known short code" do
    expect(described_class.call("http://#{host}/GeAi9K")).to eq(link)
  end

  it "returns nil when the host only ends with ours" do
    expect(described_class.call("http://not#{host}/GeAi9K")).to be_nil
  end

  it "handles a trailing slash" do
    expect(described_class.call("http://#{host}/GeAi9K/")).to eq(link)
  end

  it "returns nil for an unknown short code" do
    expect(described_class.call("http://#{host}/unknown")).to be_nil
  end

  it "returns nil when the url has no path" do
    expect(described_class.call("http://#{host}")).to be_nil
  end
end
