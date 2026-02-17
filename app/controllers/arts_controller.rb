class ArtsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_art, only: %i[ show edit update destroy ]

  def index
    @arts = Art.all
    begin
      client = MetMuseum::Client.new

      # Use the precomputed image-bearing id cache populated by ImageCacheJob.
      ids = client.fetch_image_object_ids || client.fetch_object_ids

      # Try a larger sample and collect until we have up to 6 images.
      candidate_ids = ids.sample([ids.size, 60].min)
      images = []
      candidate_ids.each do |id|
        break if images.size >= 3
        obj = client.fetch_object(id)
        next unless obj && obj["primaryImage"].present?
        images << {
          src: obj["primaryImage"],
          title: obj["title"],
          artist: obj["artistDisplayName"],
          date: obj["objectDate"],
          medium: obj["medium"],
          department: obj["department"],
          culture: obj["culture"],
          objectURL: obj["objectURL"],
          objectID: obj["objectID"]
        }
      end
      @external_images = images
    rescue => e
      Rails.logger.debug("Arts#index MetMuseum error: #{e.class} #{e.message}")
      @external_images = []
    end
  end

  def show
  end

  def new
    @art = Art.new
  end

  def create
    @art = Art.new(art_params)
    if @art.save
      redirect_to @art
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @art.update(art_params)
      redirect_to @art
    else
      render :edit, status: :unprocessable_entity
    end
  end

    def destroy
    @art.destroy
    redirect_to arts_path
  end


  private
    def set_art
      @art = Art.find(params[:id])
      if @art.met_object_id.present?
        begin
          client = MetMuseum::Client.new
          @met_object = client.fetch_object(@art.met_object_id)
        rescue => e
          Rails.logger.debug("Arts#set_art: failed to fetch met object #{@art.met_object_id}: #{e.class} #{e.message}")
          @met_object = nil
        end
      end
    end

    def art_params
      params.expect(art: [ :name, :description, :featured_image, :inventory_countr ])
    end
end
