class NeighborhoodsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin, :except => [:show]
  
  # GET /neighborhoods
  # GET /neighborhoods.json
  def index
    @neighborhoods = Neighborhood.all(:order => 'state, city')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @neighborhoods }
    end
  end

  # GET /neighborhoods/1
  # GET /neighborhoods/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @neighborhood }
    end
  end

end
