require "test_helper"

class ArtTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "sends email notifications when back in stock" do
    art = arts(:vase)

    # Set product out of stock
    art.update(inventory_count: 0)

    assert_emails 2 do
      art.update(inventory_count: 99)
    end
  end
end
