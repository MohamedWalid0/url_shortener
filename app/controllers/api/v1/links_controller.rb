class Api::V1::LinksController < ApplicationController
  before_action :validate_url, only: [ :encode, :decode ]

  def encode
    link = EncodeUrlService.call(url_params[:url])
    return render json: { error: "could not encode url" }, status: :unprocessable_entity if link.nil?

    render json: serialize(link)
  end

  def decode
    link = DecodeUrlService.call(url_params[:url])
    return render json: { error: "short url not found" }, status: :not_found if link.nil?

    render json: serialize(link)
  end

  private

  def url_params
    params.permit(:url)
  end

  def serialize(link)
    LinkBlueprint.render(link, base_url: request.base_url)
  end

  def validate_url
    return if HttpUrlValidator.valid?(url_params[:url])

    render json: { error: "invalid url" }, status: :unprocessable_entity
  end
end
