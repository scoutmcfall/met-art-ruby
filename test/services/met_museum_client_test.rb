require "test_helper"

class MetMuseumClientTest < ActiveSupport::TestCase
  test "random_cached_id uses cached ids" do
    Rails.cache.write("met_museum_object_ids", [ 10, 20, 30 ])
    client = MetMuseum::Client.new
    assert_includes [ 10, 20, 30 ], client.random_cached_id
  end
end
