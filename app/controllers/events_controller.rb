class EventsController < ApplicationController
  before_filter :find_event, :except => [:index, :my_events, :new, :create]
  before_filter :authenticate_user!, except: [:index, :show, :attendees]
  before_filter :find_venue, :only => [:create, :update]
  #before_filter :checkDate, :only => [:create, :update]
  # GET /events
  # GET /events.json
 # def checkDate
  #  @events.date = DateTime.strptime(Event.date, "%Y-%m-%d")
  #  @events.save
 # end
 
  EVENTS_PER_PAGE = 20

  def my_events
    @upcomings_attends = current_user.attends.future.limit(EVENTS_PER_PAGE)
    @attended_events = current_user.attends.completed.limit(EVENTS_PER_PAGE)
    @upcoming_hostings = current_user.hostings.future.limit(EVENTS_PER_PAGE)
    @hosted_events = current_user.hostings.completed.limit(EVENTS_PER_PAGE)
    @recommended_events = []

    respond_to do |format|
      format.html # my_events.html.erb
      format.json { render json: @events }
    end
  end

  def index
    # FIXME: eventually implement "load more" or auto-load more on scroll to bottom
    @events = Event.future.order(:start_time).limit(EVENTS_PER_PAGE)

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
    @venue = Venue.new
    @event.host = current_user
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @venue = Venue.new
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @event.host = current_user
    @event.venue = @venue
    
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        collate_when_errors
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event.venue = @venue
    
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        collate_when_errors
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
      format.html { redirect_to @event, notice: 'You are signed up to attend this event' }
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

  # POST /events/1/confirm
  # POST /events/1/confirm.json
  def confirm
    @attend = current_user.attendances.where(:event_id => @event.id).first
    if @attend.blank?
      # FIXME: if they know the secret, should we retroactively create an attend???
      render_error(:message => "You did not attend that event.", :status => 403)
    else
      if @attend.event.occurred?
        if params[:event][:secret].downcase.strip === @event.secret.downcase.strip
          @attend.update_attribute(:confirmed, true)
          respond_to do |format|
            message = 'Your attendance has been confirmed'
            format.js { render :partial => 'layouts/update_alerts', :locals => {:notice => message } }
            format.html { redirect_to @event, notice: message }
          end
        else
          render_error(:message => "Incorrect secret", :status => 403)
        end
      else
        render_error(:message => "You may not confirm your attendance until the event has occurred", :status => 403)
      end
    end
  end
  
  # GET /events/1/attendees
  # GET /events/1/attendees.json
  def attendees
    @attendees = @event.attendees
    
    respond_to do |format|
      format.html { render :partial => 'attendees' }
      format.json { render json: @attendees }
    end
  end
  
  protected
  def find_event
    begin
      @event = Event.find_by_uuid(params["id"])
    rescue Exception => e
      render_error(:message => "Event not found.", :status => 404) if @event.blank?
    end
  end  
  
  def find_venue
    @venue = Venue.find_by_uuid(params[:event][:venue_id])
    params[:event].delete(:venue_id)
  end
  
  def collate_when_errors
    when_errors = []
    [:start_date, :start_time, :end_date, :end_time].each do |attr|
      when_errors << @event.errors.full_message(attr, @event.errors[attr].join(', ')) unless @event.errors[attr].blank?
    end
    when_errors = when_errors.flatten.compact
    @event.errors.add(:when, when_errors.flatten.join('; ')) unless when_errors.blank?
  end
end
