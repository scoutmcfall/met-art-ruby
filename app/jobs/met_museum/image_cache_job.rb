module MetMuseum
  class ImageCacheJob < ApplicationJob
    queue_as :default

    # Queries to seed searches that commonly return image-bearing objects.
    QUERIES = ("a".."z").to_a + ["the", "art", "painting", "portrait"]

    def perform
      client = Client.new
      ids = []
      QUERIES.each do |q|
        begin
          ids.concat(client.search_object_ids(q: q, has_images: true) || [])
        rescue => e
          Rails.logger.error("MetMuseum::ImageCacheJob search #{q} failed: #{e.class} #{e.message}")
        end
      end

      ids = ids.map(&:to_i).uniq
      Rails.cache.write("met_museum_image_object_ids", ids, expires_in: 24.hours)
    end
  end
end
