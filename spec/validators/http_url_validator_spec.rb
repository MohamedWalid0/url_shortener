require 'rails_helper'

RSpec.describe HttpUrlValidator do
  it "accepts http and https urls that have a host" do
    expect(described_class.valid?("http://example.com/page")).to be(true)
    expect(described_class.valid?("https://example.com/page")).to be(true)
  end

  it "rejects other schemes, missing hosts, malformed and blank urls" do
    expect(described_class.valid?("ftp://example.com/file")).to be(false)
    expect(described_class.valid?("http://")).to be(false)
    expect(described_class.valid?("not a url")).to be(false)
    expect(described_class.valid?(nil)).to be(false)
  end
end
