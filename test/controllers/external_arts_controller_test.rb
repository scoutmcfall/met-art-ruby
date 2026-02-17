require "test_helper"

class ExternalArtsControllerTest < ActionDispatch::IntegrationTest
  test "GET /art/random returns selected fields" do
    sample = {
      "objectID" => 1,
      "title" => "Title",
      "artistDisplayName" => "Artist",
      "objectDate" => "2020",
      "medium" => "Oil",
      "primaryImage" => "http://example.com/image.jpg",
      "department" => "Paintings",
      "culture" => "Western",
      "objectURL" => "http://example.com"
    }

    MetMuseum::Client.class_eval do
      define_method(:random_cached_id) { 1 }
      define_method(:fetch_object) { |id| sample }
    end

    get "/art/random"
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body["objectID"]
    assert_equal "Title", body["title"]
  end
end
