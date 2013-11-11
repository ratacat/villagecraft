class WorkshopsController < ApplicationController
  before_filter :require_admin, :only => [:index]
  
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

  protected
  def find_workshop
    begin
      @workshop = Workshop.find_by_uuid(params["id"].split('-').first)
    rescue Exception => e
    end
    render_error(:message => "workshop #{params["id"]} not found.", :status => 404) if @workshop.blank?
  end  
  
end
