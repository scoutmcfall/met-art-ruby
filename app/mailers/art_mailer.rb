class ArtMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.art_mailer.in_stock.subject
  #
  def in_stock(subscriber, art)
    @subscriber = subscriber
    @greeting = "Hi art enthusiast!"

    @art = art
  mail to: subscriber.email, subject: "In stock"
  end
end
