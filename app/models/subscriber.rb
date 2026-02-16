class Subscriber < ApplicationRecord
  belongs_to :art

  # Generates a one-time token for a given purpose (like unsubscribe)
  def generate_token_for(purpose)
    # You can use Rails signed ID system
    signed_id(purpose: purpose, expires_in: 7.days)
  end
end
