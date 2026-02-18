require "test_helper"

class MetMuseumClientTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  test "random_cached_id uses cached ids" do
    Rails.cache.write(MetMuseum::Client::OBJECT_IDS_CACHE_KEY, [ 10, 20, 30 ])
    client = MetMuseum::Client.new
    assert_includes [ 10, 20, 30 ], client.random_cached_id
  end

  test "random_cached_id fetches IDs if cache is empty" do
    client = MetMuseum::Client.new

    # Stub fetch_object_ids on this instance
    def client.fetch_object_ids
      [ 100, 200, 300 ]
    end

    random_id = client.random_cached_id
    assert_includes [ 100, 200, 300 ], random_id
  end
end
