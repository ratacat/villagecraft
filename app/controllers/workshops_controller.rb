class WorkshopsController < ApplicationController
  before_filter :find_workshop, :except => [:index, :my_workshops, :new]
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :require_admin, :only => [:index]
  before_filter :require_host, :only => [:my_workshops]
  
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
    @future_reruns = @workshop.events.future.ordered_by_earliest_start_time.to_a
    @past_reruns = @workshop.events.past.ordered_by_latest_end_time.to_a
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
    @venue = Venue.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
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
