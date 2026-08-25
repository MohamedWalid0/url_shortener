require 'rails_helper'

RSpec.describe "Api::V1::Links", type: :request do
  let(:url) { "https://codesubmit.io/library/react" }

  describe "POST /api/v1/encode" do
    it "returns the original url and a short url on this host" do
      post "/api/v1/encode", params: { url: url }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        "id" => Link.last.id,
        "original_url" => url,
        "short_url" => "http://www.example.com/#{Link.last.short_code}"
      )
    end

    it "returns the same short url when the same url is encoded twice" do
      post "/api/v1/encode", params: { url: url }
      short_url = response.parsed_body["short_url"]

      expect { post "/api/v1/encode", params: { url: url } }.not_to change(Link, :count)
      expect(response.parsed_body["short_url"]).to eq(short_url)
    end

    it "rejects an invalid url" do
      post "/api/v1/encode", params: { url: "not a url" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["error"]).to eq("invalid url")
    end
  end

  describe "POST /api/v1/decode" do
    it "returns the original url for a short url handed out by encode" do
      post "/api/v1/encode", params: { url: url }
      short_url = response.parsed_body["short_url"]

      post "/api/v1/decode", params: { url: short_url }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("id" => Link.last.id, "original_url" => url, "short_url" => short_url)
    end

    it "returns not found for an unknown short url" do
      post "/api/v1/decode", params: { url: "http://www.example.com/unknown" }

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("short url not found")
    end

    it "rejects an invalid url" do
      post "/api/v1/decode", params: { url: "not a url" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["error"]).to eq("invalid url")
    end
  end
end
