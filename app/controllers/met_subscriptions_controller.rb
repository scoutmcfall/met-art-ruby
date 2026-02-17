class MetSubscriptionsController < ApplicationController
  before_action :require_authentication

  def create
    object_id = params[:object_id].to_i
    subscription = current_user_subscriptions.where(met_object_id: object_id).first_or_initialize
    if subscription.save
      head :created
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    object_id = params[:object_id].to_i
    subscription = current_user_subscriptions.find_by(met_object_id: object_id)
    if subscription
      subscription.destroy
      head :no_content
    else
      head :not_found
    end
  end

  private
    def current_user_subscriptions
      Current.user.met_subscriptions
    end
end
