# Enqueue a background job to warm the Met Museum object ID cache on boot.
# This will not block boot; failures are logged.
begin
  if Rails.application.config.respond_to?(:eager_load)
    MetMuseum::CacheJob.perform_later if defined?(MetMuseum::CacheJob)
    MetMuseum::ImageCacheJob.perform_later if defined?(MetMuseum::ImageCacheJob)
  end
rescue => e
  Rails.logger.error("MetMuseum initializer failed to enqueue cache job: #{e.class} #{e.message}")
end
