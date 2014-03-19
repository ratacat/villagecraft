class NeighborhoodsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  
  # GET /neighborhoods
  # GET /neighborhoods.json
  def index
    @county = params[:county]
    @state = (params[:state] || 'CA')
    if @county
      @neighborhoods = Neighborhood.where(:state => @state).where(:county => @county).order('state, city')
    else
      @neighborhoods = Neighborhood.all(:order => 'state, city')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @neighborhoods }
    end
  end
  
  # GET /neighborhoods/counties(.:format) 
  def counties
    @states_n_counties = Neighborhood.select([:state, :county]).group([:state, :county]).order([:state, :county])
  end

  # GET /neighborhoods/1
  # GET /neighborhoods/1.json
  def show
    @neighborhood = Neighborhood.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @neighborhood }
    end
  end

  # GET /neighborhoods/new
  # GET /neighborhoods/new.json
  def new
    @neighborhood = Neighborhood.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @neighborhood }
    end
  end

  # GET /neighborhoods/1/edit
  def edit
  end

  # create new neighborhood from given KML
  # POST /neighborhoods
  # POST /neighborhoods.json
  def create
    name = params[:neighborhood][:name]
    kml = params[:neighborhood][:_kml]

    kml.gsub! /<name>.*<\/name>/, "<name>#{name}</name>"

    Neighborhood.new_from_kml(kml, name)

    redirect_to edit_neighborhood_path(Neighborhood.last), notice: 'Neighborhood successfully created.'
  end

  # PUT /neighborhoods/1
  # PUT /neighborhoods/1.json
  def update
    respond_to do |format|
      if @neighborhood.update_attributes(params[:neighborhood])
        format.html { redirect_to @neighborhood, notice: 'Neighborhood was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @neighborhood.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /neighborhoods/1
  # DELETE /neighborhoods/1.json
  def destroy
    @neighborhood.destroy

    respond_to do |format|
      format.html { redirect_to neighborhoods_url }
      format.json { head :no_content }
    end
  end
  

end
