class SubscribersController < ApplicationController
  allow_unauthenticated_access
  before_action :set_art

  def create
    @art.subscribers.where(subscriber_params).first_or_create
    redirect_to @art, notice: "You are now subscribed."
  end

  private
    def set_art
      @art = Art.find(params[:art_id])
    end

    def subscriber_params
      params.expect(subscriber: [ :email ])
    end
end
