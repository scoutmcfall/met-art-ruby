# Simple client for The Met Museum Collection API.
require "net/http"
require "json"
require "uri"
require "digest"

module MetMuseum
  class Client
    BASE_URL = "https://collectionapi.metmuseum.org/public/collection/v1"
    OBJECT_IDS_CACHE_KEY = "met_museum_object_ids"
    IMAGE_IDS_CACHE_KEY = "met_museum_image_object_ids"

    DEFAULT_TIMEOUT = 5
    DEFAULT_RETRIES = 2
    CACHE_TTL = 24.hours
    SEARCH_CACHE_TTL = 12.hours

    class Error < StandardError; end

    def initialize(timeout: DEFAULT_TIMEOUT, retries: DEFAULT_RETRIES)
      @timeout = timeout
      @retries = retries
    end

    # Public: Fetch and cache all object IDs.
    # Will NOT overwrite existing cache with empty results.
    def fetch_object_ids
      Rails.cache.fetch(OBJECT_IDS_CACHE_KEY, expires_in: CACHE_TTL) do
        ids = fetch_object_ids_from_api

        if ids.present?
          ids
        else
          Rails.logger.warn("MetMuseum: received empty objectIDs — preserving existing cache")
          raise Error, "Failed to fetch object IDs"
        end
      end
    rescue Error
      Rails.cache.read(OBJECT_IDS_CACHE_KEY) || []
    end

    # Public: Search for object IDs using the search endpoint.
    def search_object_ids(q:, has_images: true)
      return [] if q.to_s.strip.blank?

      cache_key = search_cache_key(q, has_images)

      Rails.cache.fetch(cache_key, expires_in: SEARCH_CACHE_TTL) do
        ids = search_object_ids_from_api(q: q, has_images: has_images)

        if ids.present?
          ids
        else
          Rails.logger.warn("MetMuseum: search returned empty results for query=#{q.inspect}")
          raise Error, "Search returned empty results"
        end
      end
    rescue Error
      Rails.cache.read(cache_key) || []
    end

    # Public: Fetch cached IDs known to have images.
    # Falls back safely if empty.
    def fetch_image_object_ids
      Rails.cache.fetch(IMAGE_IDS_CACHE_KEY, expires_in: CACHE_TTL) do
        result = search_object_ids(q: "art", has_images: true)

        if result.present?
          result
        else
          Rails.logger.warn("MetMuseum: image search fallback to full object list")
          fetch_object_ids
        end
      end
    end

    def random_cached_id
        ids = Rails.cache.read(OBJECT_IDS_CACHE_KEY)
        if ids.blank?
            ids = fetch_object_ids
            Rails.cache.write(OBJECT_IDS_CACHE_KEY, ids) if ids.present?
        end

        return nil if ids.blank?

        ids.sample
    end


    # Public: Fetch full object details by ID.
    def fetch_object(object_id)
      return nil if object_id.blank?

      request_json("objects/#{object_id}")
    end

    private

    # -------------------------
    # API Methods
    # -------------------------

    def fetch_object_ids_from_api
      data = request_json("objects")
      Array(data&.dig("objectIDs")).map(&:to_i)
    end

    def search_object_ids_from_api(q:, has_images:)
      params = { q: q }
      params[:hasImages] = true if has_images

      query_string = URI.encode_www_form(params)
      data = request_json("search?#{query_string}")

      Array(data&.dig("objectIDs")).map(&:to_i)
    end

    # -------------------------
    # HTTP Layer
    # -------------------------

    def request_json(path)
      url = "#{BASE_URL}/#{path}"  # safe concatenation
      uri = URI.parse(url)
      retries = 0

      begin
        response = perform_request(uri)

        unless response.is_a?(Net::HTTPSuccess)
          Rails.logger.error("MetMuseum: non-success response #{response.code} from #{uri}")
          return nil
        end

        JSON.parse(response.body)
      rescue JSON::ParserError => e
        Rails.logger.error("MetMuseum: invalid JSON from #{uri} - #{e.message}")
        nil
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        if retries < @retries
          retries += 1
          Rails.logger.warn("MetMuseum: timeout (#{retries}/#{@retries}) retrying #{uri}")
          retry
        end

        Rails.logger.error("MetMuseum: timeout fetching #{uri} - #{e.class}: #{e.message}")
        nil
      rescue StandardError => e
        Rails.logger.error("MetMuseum: error fetching #{uri} - #{e.class}: #{e.message}")
        nil
      end
    end

    def perform_request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = @timeout
      http.open_timeout = @timeout

      request = Net::HTTP::Get.new(uri.request_uri)
      request["Accept"] = "application/json"

      http.request(request)
    end

    # -------------------------
    # Cache Helpers
    # -------------------------

    def search_cache_key(query, has_images)
      digest = Digest::MD5.hexdigest("#{query}-#{has_images}")
      "met_museum_search_#{digest}"
    end
  end
end
