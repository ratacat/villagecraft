class VenuesController < ApplicationController
  before_filter :load_venue, :except => [:index, :new, :create, :my_venues]
  authorize_resource
  
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
    @workshops = @venue.workshops.order(:created_at)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @venue }
    end
  end

  # GET /venues/new
  # GET /venues/new.json
  def new
    @venue = Venue.new
    @venue.build_location

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
    @venue = Venue.new(venue_params)
    @venue.owner = current_user
    if params[:use_as_venue_for_event]
      @event = Event.find_by_uuid(params[:use_as_venue_for_event])
      @venue.owner = @event.host if admin_session?  #admin acting on behalf of event host
    end
    respond_to do |format|
      if @venue.save
        @event.update_attribute(:venue, @venue) unless @event.blank?
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
      if @venue.update_attributes(venue_params)
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
    @venues = 
      if admin_session?
        User.find_by_uuid(params[:for_user]).try(:owned_venues)
      else
        current_user.owned_venues
      end
    @venues ||= []
    respond_to do |format|
      format.json {
        @venues = [Venue.new(:name => 'TBD')] + @venues
        @venues += [Venue.new(:name => 'Add new venue...')] if params[:add_new]
        render :json => @venues.map {|v| {:value => v.uuid, :text => v.name}}
      }
      format.html
    end
  end

  def get_venue_address
    respond_to do |format|
      format.json { render :json => {address: @venue.location}, :status => :ok }
    end
  end
  
  protected
  def venue_params
    params[:venue].permit(:name, {:location => [:street, :city, :state_code]}, :address)
  end
  
  def load_venue
    @venue = Venue.find_by_uuid(params[:id])
  end
end
