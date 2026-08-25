class LinkBlueprint < Blueprinter::Base
  identifier :id

  field :original_url

  field :short_url do |link, options|
    "#{options[:base_url]}/#{link.short_code}"
  end
end
