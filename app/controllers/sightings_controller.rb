class SightingsController < ApplicationController
  load_and_authorize_resource
  def index
    @sightings = Sighting.order(:created_at).reverse_order.limit(200)
  end
end
