class WorkshopsController < ApplicationController
  before_filter :find_workshop, :except => [:index, :my_workshops, :new, :create]
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :require_admin, :only => [:index]
  before_filter :require_host, :only => [:my_workshops]
  before_filter :only => [:edit, :update] { |c| c.be_host_or_be_admin(@workshop) }
  
  def my_workshops
    @workshops = Workshop.where(:host_id => current_user).order(:updated_at).reverse_order
    
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
    @future_reruns = @workshop.events.future.ordered_by_earliest_meeting_start_time.to_a
    @past_reruns = @workshop.events.past.ordered_by_latest_meeting_end_time.to_a
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workshop }
    end
  end

  # GET /workshops/new
  # GET /workshops/new.json
  def new
    @workshop = Workshop.new
    @workshop.host = current_user
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /workshops/1/edit
  def edit
    @future_reruns = @workshop.events.future.ordered_by_earliest_meeting_start_time.to_a
  end

  # GET /workshops/1/reruns_partial
  def reruns_partial
    @reruns = @workshop.events.future.ordered_by_earliest_meeting_start_time.to_a
    render :partial => 'reruns/index', :locals => {:reruns => @reruns, :click_to_show => false, :show_icons => true}
  end

  # POST /workshops
  # POST /workshops.json
  def create
    @workshop = Workshop.new(params[:workshop])
    @workshop.host = current_user
    
    respond_to do |format|
      if @workshop.save
        format.html { redirect_to edit_workshop_path(@workshop), notice: 'Now describe your workshop and schedule the first one.' }
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
      if @workshop.update_attributes(params[:workshop])
        format.html { redirect_to edit_workshop_path(@workshop), notice: 'Workshop successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workshop.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # POST /workshops/1/auto_add_rerun
  def auto_add_rerun
    Event.auto_create_from_workshop(@workshop)
    respond_to do |format|
      format.js { head :no_content }
    end
  end

  protected
  def find_workshop
    begin
      @workshop = Workshop.find_by_uuid(params["id"].split('-').first)
    rescue Exception => e
    end
    render_error(:message => "workshop #{params["id"]} not found.", :status => 404) if @workshop.blank?
  end  
  
end
