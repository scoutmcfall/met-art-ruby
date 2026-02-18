class MetSubscriptionsController < ApplicationController
  before_action :require_authentication

  def create
    object_id = params[:object_id].to_i
    subscription = current_user_subscriptions.where(met_object_id: object_id).first_or_initialize
    if subscription.save
      begin
        client = MetMuseum::Client.new
        object = client.fetch_object(object_id)
        if object.present?
          Art.create_from_met_for_user!(object, Current.user)
        end
      rescue => e
        Rails.logger.debug("MetSubscriptions#create: failed to create Art from met object #{object_id}: #{e.class} #{e.message}")
      end

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
      # remove user-scoped Art created from this met object if present
      art = Art.find_by(user_id: Current.user.id, met_object_id: object_id)
      art&.destroy
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
