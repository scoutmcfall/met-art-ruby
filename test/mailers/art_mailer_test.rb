# require "test_helper"

# class ArtMailerTest < ActionMailer::TestCase
#   test "in_stock" do
#     subscriber = subscribers(:one) # make sure this fixture exists
#     art = arts(:vase)               # make sure this fixture exists

#     mail = ArtMailer.in_stock(subscriber, art)
#     assert_not_nil subscriber

#     assert_equal "In stock", mail.subject
#     assert_equal [ subscriber.email ], mail.to
#     assert_equal [ "from@example.com" ], mail.from
#     assert_match "Hi", mail.body.encoded
#     assert_match art.name, mail.body.encoded
#   end
# end
