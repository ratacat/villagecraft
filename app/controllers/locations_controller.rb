class LocationsController < ApplicationController
  # doesn't do what you'd think it would; only updates session
  def update
    @location = Location.find_or_initialize_by_address(params[:location][:address])

    respond_to do |format|
      if @location.save
        session[:location_id] = @location.id
        format.json { render json: {:address_contains_city_state => @location.address_contains_city_state, :location => @location}, status: :ok  }
      else
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end
end
