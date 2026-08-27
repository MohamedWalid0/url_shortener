class DecodeUrlService
  HOST = "web-production-994b4.up.railway.app".freeze

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @uri = URI.parse(url)
  end

  def call
    return unless our_host?

    Link.find_by(short_code: short_code)
  end

  private

  attr_reader :uri

  def our_host?
    uri.host.casecmp?(HOST)
  end

  def short_code
    uri.path.split("/").last
  end
end
