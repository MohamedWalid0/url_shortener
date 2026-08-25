class Link < ApplicationRecord
  validates :original_url, presence: true, http_url: true
  validates :short_code, uniqueness: true, allow_nil: true
end
