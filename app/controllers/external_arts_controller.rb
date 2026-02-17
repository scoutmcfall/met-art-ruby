class ExternalArtsController < ApplicationController
  allow_unauthenticated_access

  # GET /art/random
  def random
    client = MetMuseum::Client.new
    object_id = client.random_cached_id
    unless object_id
      render json: { error: "no_ids_available" }, status: :service_unavailable and return
    end

    begin
      object = client.fetch_object(object_id)
    rescue MetMuseum::Client::Error => e
      render json: { error: "external_api_error" }, status: :bad_gateway and return
    end

    if object.blank?
      render json: { error: "not_found" }, status: :not_found and return
    end

    render json: object.slice(
      "objectID",
      "title",
      "artistDisplayName",
      "objectDate",
      "medium",
      "primaryImage",
      "department",
      "culture",
      "objectURL"
    )
  end

  # GET /met_objects/:object_id
  # show action removed (modal fetch removed)
end
