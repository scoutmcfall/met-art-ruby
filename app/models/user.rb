class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :met_subscriptions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.authenticate_by(params)
    email = params[:email_address]&.to_s&.strip&.downcase
    return nil unless email.present? && params[:password].present?
    user = find_by(email_address: email)
    return user if user&.authenticate(params[:password])
    nil
  end
end
