class MetSubscription < ApplicationRecord
  belongs_to :user

  validates :met_object_id, presence: true, numericality: { only_integer: true }
  validates :user_id, presence: true
  validates :met_object_id, uniqueness: { scope: :user_id }
end
