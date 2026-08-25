class DecodeUrlService
  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url
  end

  def call
    code = short_code
    return if code.blank?

    Link.find_by(short_code: code)
  end

  private

  attr_reader :url

  def short_code
    URI.parse(url.to_s).path.split("/").last
  rescue URI::InvalidURIError
    nil
  end
end
