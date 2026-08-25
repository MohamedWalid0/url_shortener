class HttpUrlValidator < ActiveModel::EachValidator
  def self.valid?(value)
    uri = URI.parse(value.to_s)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    return if self.class.valid?(value)

    record.errors.add(attribute, "is not a valid http url")
  end
end
