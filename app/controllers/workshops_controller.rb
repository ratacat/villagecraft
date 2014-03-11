class WorkshopsController < ApplicationController
  
  # hacky inter-op between cancan and strong_parameters (see: https://github.com/ryanb/cancan/issues/571); FIXME: when we upgrade to Rails 4
  before_filter do
    params[:workshop] &&= workshop_params
  end
  load_and_authorize_resource(:find_by => :seod_uuid)
  
  before_filter :get_future_and_past_reruns, :only => [:edit, :update, :show]
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
    @workshops = Workshop.order(:created_at)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workshops }
    end
  end

  # GET /workshops/1
  # GET /workshops/1.json
  def show
    # w.events.joins(:meetings).order('"meetings"."start_time"')
    respond_to do |format|
      format.html {
        if params[:v] == 'alt'
          render 'show_alt'
        else
          render 'show'
        end
      }
      format.json { render json: @workshop }
    end
  end

  # GET /workshops/new
  # GET /workshops/new.json
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

  # GET /workshops/1/edit
  def edit
    @add_button_help =
      if @future_reruns.count + @past_reruns.count == 0
        'When you are happy with the title, description, and photo for your workshop, schedule the first occurance'
      else
        'Offer this workshop again'
      end
  end

  # GET /workshops/1/reruns_partial
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
  
  # PUT /workshops/1
  # PUT /workshops/1.json
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
  
  # POST /workshops/1/auto_add_rerun
  def auto_add_rerun
    Event.auto_create_from_workshop(@workshop)
    respond_to do |format|
      format.html { redirect_to edit_workshop_path(@workshop), notice: 'A new date for this workshop has been scheduled (see below)' }
      format.js { head :no_content }
    end
  end

  # DELETE /workshops/1
  # DELETE /workshops/1.json
  def destroy
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
end
