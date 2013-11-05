class EventsController < ApplicationController
  include PublicActivity::ViewHelpers
  
  before_filter :find_event, :except => [:index, :my_events, :new, :create]
  before_filter :authenticate_user!, except: [:index, :show, :attendees, :attend_by_email]
  before_filter :require_admin, :only => [:index, :destroy]
  before_filter :require_host, :only => [:my_events]
  before_filter :find_venue, :only => [:create, :update]
  before_filter :be_host_or_be_admin, :only => [:edit, :update, :manage_attendances, :accept_attendee, :cancel_attend]
  
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

    respond_to do |format|
      format.html # my_events.html.erb
      format.json { render json: @events }
    end
  end

  def index
    # FIXME: eventually implement "load more" or auto-load more on scroll to bottom
    @future_events = Event.future.order(:start_time) # .limit(EVENTS_PER_PAGE)
    @past_events = Event.past.order(:start_time) # .limit(EVENTS_PER_PAGE)

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
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @event.host = current_user
    @event.venue = @venue
    
    respond_to do |format|
      if @event.save
        @event.create_activity :create, owner: current_user
        format.html { redirect_to root_path, notice: 'Event was successfully created.' }
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
      @event.assign_attributes(params[:event])
      @event.derive_times
      @changes = @event.changes
      if @event.save
        if @changes[:start_time] or @changes[:end_time]
          @event.create_activity key: 'event.time_changed', 
                                 owner: current_user, 
                                 parameters: {:new_time => render_to_string(:partial => 'events/times', :layout => false, :locals => {:event => @event})}
        end
        if @changes[:venue_id]
          @event.create_activity key: 'event.venue_changed', 
                                 owner: current_user, 
                                 parameters: {:new_venue_id => @event.venue_id}          
        end
        format.html { redirect_to root_path, notice: 'Event was successfully updated.' }
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
    if @event.slots_left > 0
      render_error(:message => "Event is full", :status => 403)
      return
    end
    
    begin
      attendance = current_user.attendances.build
      attendance.event = @event
#      attendance.message = params[:attendance][:message]
      attendance.save!
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html { redirect_to root_path, notice: "You are already attending this event" }
        format.json { head :no_content }
      end
      return
    end
    
    @event.create_activity key: 'event.interested', owner: current_user
    
    respond_to do |format|
      format.html { redirect_to root_path, notice: %Q(You signed up to attend "#{@event.title}") }
      format.json { head :no_content }
    end
    
  end
  
  # POST /attend_by_email/1
  # POST /attend_by_email/1.json
  def attend_by_email
    @user = User.find_by_email(params[:email])
    if @user
      UserMailer.click_to_sign_in_and_attend(@user, @event).deliver
      render json: {message: 'User sent click-to-attend email'}, :status => :ok # 200
    else
      render json: {message: 'User not found'}, :status => :not_found # 404
    end
  end
  
  # POST /cancel_attend/1
  # POST /cancel_attend/1.json
  def cancel_attend
    if params[:user_uuid]
      return unless be_host_or_be_admin
      @user = User.find_by_uuid(params[:user_uuid])
      if @user.blank?
        render_error(:message => "User not found.", :status => 404)
        return
      end
    else
      @user = current_user
    end
    
    unless @user.attends.exists?(@event)
      render_error(:message => "Attendence not found.", :status => 404)
      return
    end

    @user.attends.delete(@event)
    if @user == current_user
      @event.create_activity key: 'event.cancel_attend', owner: @user
    else
      @event.create_activity key: 'event.host_cancels_attend', owner: @user
    end

    respond_to do |format|
      @notice = be_host_or_be_admin ? "#{@user.name}'s attendence has been canceled" : 'Your attendence has been canceled'
      format.js
      format.html {
        if be_host_or_be_admin
          redirect_to manage_attendances_path(@event), notice: @notice
        else
          redirect_to @event, notice: @notice 
        end
      }
      format.json { head :no_content }
    end
    
  end
  
  # POST /events/:id/accept_attendee
  def accept_attendee
    attendance = Attendance.find_by_uuid(params[:attendance_uuid])
    if attendance.blank?
      render_error(:message => "Cannot find attendance #{attendance.uuid}", :status => 403)
    elsif attendance.event != @event
      render_error(:message => "Attendance / event mismatch", :status => 403)
    elsif not attendance.interested?
      render_error(:message => "Cannot accept attendee #{attendance.user.uuid}, who is in state #{attendace.state}", :status => 403)
    else
      attendance.accept!
      @event.create_activity key: 'event.attend', owner: current_user
      respond_to do |format|
        format.html { redirect_to manage_attendances_path(@event), notice: "#{attendance.user.name} accepted" }
        format.json { head :no_content }
      end
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
          @attend.confirm!
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
    @attendees = @event.attendances.with_state(:attending)
    
    respond_to do |format|
      format.html { render :partial => 'attendees' }
      format.json { render json: @attendees }
    end
  end
  
  # GET /events/1/manage_attendances
  # GET /events/1/manage_attendances.json
  def manage_attendances
    # @interested = @event.attendances.with_state(:interested)
    # @attending = @event.attendances.with_state(:attending)
    # @confirmed = @event.attendances.with_state(:confirmed)
  end
  
  protected
  def find_event
    begin
      @event = Event.find_by_uuid(params["id"].split('-').first)
    rescue Exception => e
    end
    render_error(:message => "Event #{params["id"]} not found.", :status => 404) if @event.blank?
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
  
  def be_host_or_be_admin
    unless user_signed_in? and (current_user == @event.host or current_user.admin?)
      render_error(:message => "You must be the event's host or an admin to do that.", :status => :unauthorized)
      return false
    end
    return true
  end
  
end
