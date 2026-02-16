class ArtMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.art_mailer.in_stock.subject
  #
  def in_stock(subscriber, art)
      raise "Subscriber is nil!" if subscriber.nil?

    @subscriber = subscriber
    @art = art
    @greeting = "Hi art enthusiast!"

  mail to: subscriber.email, subject: "In stock"
  end
end
