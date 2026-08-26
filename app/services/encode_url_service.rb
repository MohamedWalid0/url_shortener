class EncodeUrlService
  CODE_LENGTH = 8
  MAX_ATTEMPTS = 5

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = normalize(url)
  end

  def call
    return if url.blank?

    MAX_ATTEMPTS.times do |attempt|
      link = find_or_create_link_at(short_code(attempt))
      return link if link.original_url == url
    end

    nil
  end

  private

  attr_reader :url

  # Normalize the URL to remove trailing slashes. https://example.com and https://example.com/ are the same
  def normalize(value)
    stripped = value.to_s.strip
    uri = URI.parse(stripped)
    uri.path = uri.path.sub(%r{/+\z}, "")
    uri.to_s
  rescue URI::InvalidURIError, URI::InvalidComponentError
    stripped
  end

  def short_code(attempt)
    key = attempt.zero? ? url : "#{url}#{attempt}"
    Digest::SHA1.hexdigest(key).first(CODE_LENGTH)
  end

  def find_or_create_link_at(code)
    Link.find_or_create_by!(short_code: code) { |link| link.original_url = url }
  end
end
