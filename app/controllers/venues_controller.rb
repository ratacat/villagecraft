class VenuesController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit, :update]
  before_filter :require_admin, :only => [:index, :destroy]
  before_filter :find_venue, :except => [:index, :new, :create]
  before_filter :be_owner_or_be_admin, :only => [:edit, :update]
  
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
        format.js { render :refresh_venues_select }
        format.html { redirect_to @venue, notice: 'Venue was successfully created.' }
        format.json { render json: @venue, status: :created, location: @venue }
      else
        format.js { render :replace_form }
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
  
  # GET /venues/1/neighborhood_KML
  def neighborhood_KML
    if @hood = Neighborhood.select('*, ST_AsKML(geom) as kml').where(:id => @venue.location.neighborhood_id).first
      render(:template => "locations/neighborhood", :formats => [:xml], :handlers => :builder, :layout => false, :locals => {:kml => @hood.kml})
    end
  end
  
  protected
  def find_venue
    begin
      @venue = Venue.find_by_uuid(params["id"])
    rescue Exception => e
      render_error(:message => "Venue not found.", :status => 404) if @venue.blank?
    end
  end  
  
  def be_owner_or_be_admin
    unless user_signed_in? and (current_user == @venue.owner or current_user.admin?)
      render_error(:message => "You are not authorized to edit this venue.", :status => :unauthorized)
    end
  end
  
end
