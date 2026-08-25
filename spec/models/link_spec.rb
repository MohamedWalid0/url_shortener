require 'rails_helper'

RSpec.describe Link, type: :model do
  let(:url) { "https://codesubmit.io/library/react" }

  it "is valid with an original_url and a short_code" do
    expect(Link.new(short_code: "abc123", original_url: url)).to be_valid
  end

  it "accepts both http and https urls" do
    expect(Link.new(short_code: "abc123", original_url: "http://example.com/page")).to be_valid
    expect(Link.new(short_code: "abc123", original_url: "https://example.com/page")).to be_valid
  end

  it "requires an original_url" do
    link = Link.new(short_code: "abc123")

    expect(link).not_to be_valid
    expect(link.errors[:original_url]).to include("can't be blank")
  end

  it "rejects a short_code another link already has" do
    Link.create!(short_code: "abc123", original_url: "https://example.com/other")

    link = Link.new(short_code: "abc123", original_url: url)

    expect(link).not_to be_valid
    expect(link.errors[:short_code]).to include("has already been taken")
  end

  it "rejects a url that is not http or https" do
    link = Link.new(short_code: "abc123", original_url: "ftp://example.com/file")

    expect(link).not_to be_valid
    expect(link.errors[:original_url]).to include("is not a valid http url")
  end

  it "rejects a url without a host" do
    expect(Link.new(short_code: "abc123", original_url: "http://")).not_to be_valid
  end

  it "rejects a malformed url" do
    expect(Link.new(short_code: "abc123", original_url: "not a url")).not_to be_valid
  end
end
