class EventsController < ApplicationController
  before_filter :find_event, :except => [:index, :my_events, :new, :create]
  before_filter :authenticate_user!, except: [:index, :show]
  #before_filter :checkDate, :only => [:create, :update]
  # GET /events
  # GET /events.json
 # def checkDate
  #  @events.date = DateTime.strptime(Event.date, "%Y-%m-%d")
  #  @events.save
 # end

  def my_events
    @hosted_events = current_user.hostings.order('start_time DESC')
    respond_to do |format|
      format.html # my_events.html.erb
      format.json { render json: @events }
    end
  end

  def index
    @events = Event.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    @event.host = current_user
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @event.host = current_user

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
  
  # POST /attend/1
  # POST /attend/1.json
  def attend
    begin
      current_user.attends << @event
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to @event, notice: "You are already attending this event" }
        format.json { head :no_content }
      end
      return
    end
    
    respond_to do |format|
      format.html { redirect_to @event, notice: 'You will attend!' }
      format.json { head :no_content }
    end
    
  end
  
  # POST /cancel_attend/1
  # POST /cancel_attend/1.json
  def cancel_attend
    unless current_user.attends.exists?(@event)
      render_error(:message => "Attendence not found.", :status => 404)
      return
    end

    current_user.attends.delete(@event)
        
    respond_to do |format|
      format.html { redirect_to @event, notice: 'Your attendence has been canceled' }
      format.json { head :no_content }
    end
    
  end
  
  protected
  def find_event
    begin
      @event = Event.find(params["id"])
    rescue Exception => e
      render_error(:message => "Event not found.", :status => 404) if @event.blank?
    end
  end  
  
end
