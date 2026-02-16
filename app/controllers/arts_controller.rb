class ArtsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_art, only: %i[ show edit update destroy ]

  def index
    @arts = Art.all
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
    end

    def art_params
      params.expect(art: [ :name, :description, :featured_image, :inventory_countr ])
    end
end
