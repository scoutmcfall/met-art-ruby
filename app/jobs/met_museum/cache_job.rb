module MetMuseum
  class CacheJob < ApplicationJob
    queue_as :default

    def perform
      client = Client.new
      begin
        client.fetch_object_ids
      rescue Client::Error => e
        Rails.logger.error("MetMuseum::CacheJob failed: #{e.message}")
      end
    end
  end
end
