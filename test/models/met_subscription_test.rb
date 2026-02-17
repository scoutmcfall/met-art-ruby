require "test_helper"

class MetSubscriptionTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email_address: "test@example.com", password: "password")
  end

  test "validates uniqueness per user" do
    s1 = MetSubscription.create!(user: @user, met_object_id: 123)
    s2 = MetSubscription.new(user: @user, met_object_id: 123)
    assert_not s2.save
    assert_includes s2.errors[:met_object_id], "has already been taken"
  end
end
