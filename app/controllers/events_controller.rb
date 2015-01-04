class EventsController < ApplicationController
  include PublicActivity::ViewHelpers
  # include ChargesHelper disable stripe
  load_and_authorize_resource(:find_by => :seod_uuid)
  before_filter :check_lock, :only => [:update, :destroy]
 
  # FIXME: prevent non-admins from changing events (and meetings) that have occurred
 
  EVENTS_PER_PAGE = 20

  def index
    # FIXME: eventually implement "load more" or auto-load more on scroll to bottom
    @future_events = Event.where_first_meeting_starts_in_future # .limit(EVENTS_PER_PAGE)
    @past_events = Event.where_first_meeting_starts_in_past # .limit(EVENTS_PER_PAGE)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /e/:uuid
  # GET /e/:uuid.json
  def show
    @workshop = @event.workshop
    @reviews_recent = @workshop.all_reviews(order: :created_at, reverse_order: true, limit: 3)
    @reviews_rating = @workshop.all_reviews(order: :rating, limit: 3)

    @future_reruns = @workshop.events.where_first_meeting_starts_in_future.to_a

    if @workshop.image
      @images = @workshop.images.where("#{Image.quoted_table_column(:id)} != ?", @workshop.image).order(:created_at).reverse_order
    else
      @images = @workshop.images.order(:created_at).reverse_order
    end

    respond_to do |format|
      format.html { render 'show' }
      format.json { render json: @event }
    end

    #intercom event for viewing a workshop, calling user.create in case someone tries to view an event without intercom 
    #having caught their account yet
    if user_signed_in? and Rails.env.production?
      Intercom::User.create(:id => current_user.uuid, :email => current_user.email)
      Intercom::Event.create(
        :event_name => "looked-at-workshop", 
        :created_at => Time.now.to_i,
        :email => current_user.email,
        :metadata => {
          "workshop_title" => @workshop.title,
          "http_referer" => request.env["HTTP_REFERER"]
        }
      )
    end
  end
  
  # GET /events/1/manage
  # GET /events/1.json/manage
  def manage_attendees
    if @event.manageable?
      @activities_n_counts = Activity.activities_n_counts(:limit => 20, :trackable => @event)
      respond_to do |format|
        format.html { render 'manage' }
        format.json { render json: @event }
      end
    else
      if not @event.rsvp
        render_error(:message => 'Cannot manage attendees because RSVP is not set for this workshop', :status => :unauthorized)
      elsif @event.external
        render_error(:message => 'Cannot manage attendees of an external workshop', :status => :unauthorized)
      else
        render_error(:message => 'Workshop unmanageable for some reason', :status => :unauthorized)
      end
    end
  end

  # POST /events/1/sms_attendees
  def sms_attendees
    render :json => @event.create_activity(key: 'event.sms', owner: current_user, parameters: {:message => params[:sms][:message]})
  end

  # POST /events/1/lock
  # POST /events/1.json/lock
  def lock
    @event.update_attribute(:unlocked_at, nil)
    notice = "workshop rerun locked"

    @workshop = @event.workshop

    respond_to do |format|
      format.js { head :no_content }
      format.html { 
        if request.xhr?
          render :partial => 'reruns/row', :locals => {rerun: @event, show_icons: true, click_to_show: false, editable: false}
        else
          redirect_to edit_workshop_path(@workshop), notice: notice
        end
      }
      format.json { head :no_content }
    end
  end


  # POST /events/1/unlock
  # POST /events/1.json/unlock
  def unlock
    @event.update_attribute(:unlocked_at, Time.now)
    notice = "workshop rerun unlocked for #{Event::UNLOCK_TIMEOUT} minutes"

    @workshop = @event.workshop

    respond_to do |format|
      format.js { head :no_content }
      format.html { 
        if request.xhr?
          render :partial => 'reruns/row', :locals => {rerun: @event, show_icons: true, click_to_show: false, editable: true}
        else
          redirect_to edit_workshop_path(@workshop), notice: notice
        end
      }
      format.json { head :no_content }
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
    
    respond_to do |format|
      if @event.save
        @event.create_activity :create, owner: current_user
        format.html { redirect_to root_path, notice: 'Event was successfully created.' }
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
    host = @event.host
    price = @event.price

    respond_to do |format|
      # if @event.rsvp? && (price == 0 && params[:event][:price])
      #   if host.stripe_token
      #     @event.assign_attributes(params[:event])
      #   else
      #     format.json {render status: :unauthorized }
      #   end
      # else
      #   @event.assign_attributes(params[:event])
      # end
      
      # 0d4308768a787ea4296f4d52d8acf1d3cdc83b5d Commented out refund method in events controller
      # also commented out assign_attributes; so nothing was being updated 
      @event.assign_attributes(params[:event])

      if @event.save
        format.html { redirect_to edit_workshop_path(@event.workshop), notice: 'Event was successfully updated.' }
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
    @workshop = @event.workshop
    @event.destroy

    respond_to do |format|
      format.js { head :no_content }
      format.html { redirect_to edit_workshop_path(@workshop) }
      format.json { head :no_content }
    end
  end
  
  # POST /attend/1
  # POST /attend/1.json
  def attend
    if @event.external?
      render_error(:message => "Event is external; you cannot sign up for it through Villagecraft", :status => 403)
    elsif @event.slots_left <= 0
      render_error(:message => "Event is full", :status => 403)
    elsif current_user.attending_event?(@event)
      render_error(:message => "You are already attending this event", :status => 403)
    else
      current_user.attends << @event
      @event.create_activity key: 'event.interested', owner: current_user
      
      unless (@event.workshop.greeting_subject.blank? or @event.workshop.greeting_body.blank?)
        # create the greeting email to be sent right away
        Message.create!(:from_user => @event.host,
                        :to_user => current_user, 
                        :apropos => @event, 
                        :subject => @event.workshop.greeting_subject,
                        :body => @event.workshop.greeting_body)
      end

      # late signups should be sent the warmup immediately
      mtg = @event.first_meeting
      if mtg.immediately_send_warmup_message_to_late_signup?
        Message.create!(
          :from_user => mtg.event.host, 
          :to_user => current_user,
          :send_at => 1.minute.from_now,
          :apropos => mtg.workshop,
          :subject => mtg.workshop.warmup_subject,
          :body => mtg.workshop.warmup_body)
      end
      
      respond_to do |format|
        format.html { redirect_to @event.workshop, notice: "Thanks for signing up." }
        format.json { render json: {:location => @event.location}, status: :ok  }
        format.json { head :no_content }
      end
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
      be_host_or_be_admin(@event) # FIXME: use cancan for this?
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
      @notice = 'Attendence canceled'
      format.js
      format.html {
        if current_user.is_host_of?(@event)
          redirect_to :back, notice: @notice
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
  
  protected
  def check_lock
    if @event.locked?
      raise CanCan::AccessDenied.new("Workshop locked (#{view_context.pluralize(@event.attendances.count, 'person')} attending)", action_name, Event)
    end
  end
  
  def event_params
    ok_params = [:host, :title, :description, :short_title, :min_attendees, :max_attendees, :image, :price, :venue_uuid, :external, :external_url, :rsvp]
    # XXX possibly some additional ok_params if admin_session? or current_user.host?
    params[:event].permit(*ok_params)
  end
  
end
