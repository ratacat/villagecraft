class VenuesController < ApplicationController
  load_and_authorize_resource(:find_by => :uuid)
  
  # GET /venues
  # GET /venues.json
  def index
    @venues = Venue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @venues }
    end
  end

  # GET /venues/1
  # GET /venues/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @venue }
    end
  end

  # GET /venues/new
  # GET /venues/new.json
  def new
    @venue = Venue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @venue }
    end
  end

  # GET /venues/1/edit
  def edit
  end

  # POST /venues
  # POST /venues.json
  def create
    @venue = Venue.new(params[:venue])
    @venue.owner = current_user
    
    respond_to do |format|
      if @venue.save
        Event.find_by_uuid(params[:use_as_venue_for_event]).update_attribute(:venue, @venue) if params[:use_as_venue_for_event]
        format.js { render :refresh_venues_select }
        format.html { redirect_to @venue, notice: 'Venue was successfully created.' }
        format.json { render json: @venue, status: :created, location: @venue }
      else
        format.js { render :json => { :errors => @venue.errors.full_messages, :message => "Problem creating new venue" }, :status => :unprocessable_entity }
        format.html { render action: "new" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.json
  def update
    respond_to do |format|
      if @venue.update_attributes(params[:venue])
        format.html { redirect_to @venue, notice: 'Venue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.json
  def destroy
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to venues_url }
      format.json { head :no_content }
    end
  end
  
  # GET /venues/1/neighborhood.xml (outputs KML)
  # GET /venues/1/neighborhood.json (outputs GeoJSON)
  def neighborhood
    respond_to do |format|
      format.xml { render :template => "locations/neighborhood", 
                          :formats => [:xml], :handlers => :builder, :layout => false, 
                          :locals => {:kml => @venue.location.neighborhood.as_kml} }
      format.json { render :json => @venue.location.neighborhood.as_json }
    end
  end
  
  # GET /my_venues
  # GET /my_venues.json
  def my_venues
    @venues = current_user.owned_venues
    respond_to do |format|
      format.json {
        @venues = [Venue.new(:name => 'TBD')] + @venues
        @venues += [Venue.new(:name => 'Add new venue...')] if params[:add_new]
        render :json => @venues.map {|v| {:value => v.uuid, :text => v.name}} 
      }
      format.html
    end
  end
end
