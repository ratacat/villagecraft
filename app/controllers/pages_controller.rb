class PagesController < ApplicationController
  def home
    if params[:sort]
      session[:sort_order] = params[:sort]
      redirect_to root_path
    end
    if user_signed_in?
      @location = (current_user.last_sighting.try(:location) || current_user.location)
    end
    if session[:location_id]
      @location ||= Location.find(session[:location_id])
    end
    @location ||= Location.find_or_create_by_address('Berkeley, CA')

    @workshops = Workshop.first_meeting_in_the_future
    if session[:sort_order] == 'distance'
      @scheduled_workshops_with_venue_tbd = @workshops.where(:venue_id => nil)
      @other_workshops = Workshop.where(%Q(#{Workshop.quoted_table_column(:id)} NOT IN (#{@workshops.select(Workshop.quoted_table_column(:id)).to_sql})))
        .where(%Q(#{Workshop.quoted_table_column(:id)} NOT IN (#{@scheduled_workshops_with_venue_tbd.select(Workshop.quoted_table_column(:id)).to_sql})))
      @workshops = @workshops.by_distance_from(@location)
    else
      @other_workshops = Workshop.where(%Q(#{Workshop.quoted_table_column(:id)} NOT IN (#{@workshops.select(Workshop.quoted_table_column(:id)).to_sql})))
      @workshops = @workshops.order(%Q(#{Meeting.quoted_table_column(:start_time)}))
    end
    @workshops = @workshops.to_a.uniq
  end

    # what is stripe page
  def what_is_stripe
    @user = current_user
    req = request.host_with_port
    @profile = "http://" + req + "/users/" + @user.uuid
  end

  def home_events
    if params[:sort]
      session[:sort_order] = params[:sort]
      redirect_to root_path
    end
    if user_signed_in?
      @location = (current_user.last_sighting.try(:location) || current_user.location)
    end
    if session[:location_id]
      @location ||= Location.find(session[:location_id])
    end
    @location ||= Location.find_or_create_by_address('Berkeley, CA')

    @events = Event.first_meeting_in_the_future
    if session[:sort_order] == 'distance'
      @scheduled_events_with_venue_tbd = @events.where(:venue_id => nil)
      @other_events = Event.where(%Q(#{Event.quoted_table_column(:id)} NOT IN (#{@events.select(Event.quoted_table_column(:id)).to_sql})))
      .where(%Q(#{Event.quoted_table_column(:id)} NOT IN (#{@scheduled_events_with_venue_tbd.select(Event.quoted_table_column(:id)).to_sql}))).paginate(:page => params[:page], :per_page => 30)  #limit added because it was too slow. Pagination needed
      @events = @events.by_distance_from(@location)
    else
      @other_events = Event.where(%Q(#{Event.quoted_table_column(:id)} NOT IN (#{@events.select(Event.quoted_table_column(:id)).to_sql}))).paginate(:page => params[:page], :per_page => 30) #limit added because it was too slow. Pagination needed
      @events = @events.order(%Q(#{Meeting.quoted_table_column(:start_time)}))
    end

    @events = @events.paginate(:page => params[:page], :per_page => 45).to_a.uniq
  end

  def home_events_page
    home_events
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  def about
  end
  def what_is_stripe
  end
end
