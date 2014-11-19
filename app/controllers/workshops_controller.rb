class WorkshopsController < ApplicationController
  # include ChargesHelper commented out to disable stripe
  load_and_authorize_resource(:find_by => :seod_uuid, :param_method => :workshop_params)
  before_filter :get_future_and_past_reruns, :only => [:edit, :update]
  before_filter :get_reviews, :only => [:edit, :update, :show]
  def my_workshops
    @upcoming_workshops = Workshop.first_meeting_in_the_future.where(:host_id => current_user)
    @past_workshops = Workshop.first_meeting_in_the_past.where(:host_id => current_user)
    @other_workshops = Workshop.where(:host_id => current_user).
                                where(%Q(#{Workshop.quoted_table_column(:id)} NOT IN (#{@upcoming_workshops.select(Workshop.quoted_table_column(:id)).to_sql}))).
                                where(%Q(#{Workshop.quoted_table_column(:id)} NOT IN (#{@past_workshops.select(Workshop.quoted_table_column(:id)).to_sql})))
    @upcoming_workshops = @upcoming_workshops.order(Meeting.quoted_table_column(:start_time))
    @past_workshops = @past_workshops.order(%Q(#{Meeting.quoted_table_column(:start_time)} DESC))
    @workshops = (@upcoming_workshops.to_a + @past_workshops.to_a + @other_workshops.to_a).uniq
    respond_to do |format|
      format.html # my_workshops.html.erb
      format.json { render json: @workshops }
    end
  end

  # GET /workshops
  # GET /workshops.json
  def index
    # FIXME: eventually implement "load more" or auto-load more on scroll to bottom
    @workshops = Workshop.order(:created_at).reverse_order

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workshops }
    end
  end

  # GET /w/1
  # GET /w/1.json
  def show
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
      format.json { render json: @workshop }
    end
  end
  
  # GET /w/:id/simple_index_partial(.:format) 
  def simple_index_partial
    @future_reruns = @workshop.events.where_first_meeting_starts_in_future.to_a
    render partial: 'reruns/simple_index', locals: {reruns: @future_reruns}, layout: false
  end
  
  # GET /w/1/upload_photo
  # POST /w/1/upload_photo
  def upload_photo
    if request.put?
      if params[:workshop] and params[:workshop][:image]
        @i = Image.new(:i => params[:workshop][:image], :user => current_user, :apropos => @workshop, :title => params[:workshop][:title])        
      end
      if @i.try(:save)
        @i.create_activity :upload, owner: current_user
        redirect_to workshop_path(@workshop), notice: "Image uploaded"
      else
        redirect_to upload_photo_workshop_path(@workshop), alert: "There was a problem uploading that file.  Try another."
      end
    end
  end

  # GET /w/new
  # GET /w/new.json
  def new
    @workshop = Workshop.new
    if admin_session? and params[:external]
      @workshop.external = true
    else
      @workshop.host = current_user
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /w/1/edit
  def edit
    @add_button_help =
      if @future_reruns.count + @past_reruns.count == 0
        'When you are happy with the title, description, and photo for your workshop, schedule the first occurance'
      else
        'Offer this workshop again'
      end
  end

  # GET /w/1/reruns_partial
  def reruns_partial
    @reruns = @workshop.events.where_first_meeting_starts_in_future.to_a
    render :partial => 'reruns/index', :locals => {:reruns => @reruns, :click_to_show => false, :show_icons => true, :editable => true, :update_reruns_count => true, :clear_source_cache => params[:clear_source_cache]}
  end

  # POST /workshops
  # POST /workshops.json
  def create
    @workshop = Workshop.new(workshop_params)
    unless admin_session? and @workshop.external?
      @workshop.host = current_user
    end
    
    respond_to do |format|
      if @workshop.save
        format.html { redirect_to edit_workshop_path(@workshop), notice: 'Workshop created' }
        format.json { render json: @workshop, status: :created, location: @workshop }
      else
        format.html { render action: "new" }
        format.json { render json: @workshop.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PUT /w/1
  # PUT /w/1.json
  def update
    respond_to do |format|
      if @workshop.update_attributes(workshop_params)
        format.html { redirect_to edit_workshop_path(@workshop), notice: 'Workshop successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workshop.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /w/:id/manage(.:format)
  def manage
    @attendees = @workshop.attendees.uniq
  end
  
  # POST /w/1/sms_attendees
  def sms_attendees
    render :json => @workshop.create_activity(key: 'workshop.sms', owner: current_user, parameters: {:message => params[:sms][:message]})
  end
  
  # POST /w/1/auto_add_rerun
  def auto_add_rerun
    @workshop.with_lock do
      Event.auto_create_from_workshop(@workshop)
    end
    respond_to do |format|
      format.html { redirect_to edit_workshop_path(@workshop), notice: 'A new date for this workshop has been scheduled (see below)' }
      format.js { head :no_content }
    end
  end

  # DELETE /w/1
  # DELETE /w/1.json
  def destroy
    @workshop.events.each do |event|
      event.attendees.each do |attendee|
        refund(event, attendee)
      end
    end
    @workshop.destroy

    respond_to do |format|
      format.js { head :no_content }
      format.html { redirect_to workshops_path }
      format.json { head :no_content }
    end
  end
  
  protected
  def workshop_params
    ok_params = [:title, :description, :frequency, :image, :greeting_subject, :greeting_body, :warmup_subject, :warmup_body, :reminder]
    ok_params += [:external, :external_url, :host_id] if admin_session?
    params[:workshop].permit(*ok_params)
  end
  
  def get_future_and_past_reruns
    @future_reruns = @workshop.events.where_first_meeting_starts_in_future.to_a
    @past_reruns = @workshop.events.where_first_meeting_starts_in_past.to_a
  end

  def get_reviews
    @reviews = @workshop.all_reviews
  end
end
