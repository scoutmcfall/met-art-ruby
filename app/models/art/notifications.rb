module Art::Notifications
  extend ActiveSupport::Concern

  included do
    has_many :subscribers, dependent: :destroy
    after_update_commit :notify_subscribers, if: :back_in_stock?
  end

  def back_in_stock?
    inventory_count_previously_was.zero? && inventory_count.positive?
  end

  def notify_subscribers
    subscribers.each do |subscriber|
      ArtMailer.with(art: self, subscriber: subscriber).in_stock(subscriber, self).deliver_later
    end
  end
end
