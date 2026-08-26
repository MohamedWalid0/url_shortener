class Link < ApplicationRecord
  validates :original_url, presence: true, http_url: true
end
