class PagesController < ApplicationController
  def home
    if params[:sort]
      session[:sort_order] = params[:sort]
      redirect_to root_path
    end
    if session[:location_id]
      @location = Location.find(session[:location_id])
    elsif user_signed_in?
      @location = current_user.location
    end
    @location ||= Location.find_or_create_by_address('Berkeley, CA')

    @workshops = Workshop.first_meeting_in_the_future
    if session[:sort_order] == 'distance'
      @scheduled_workshops_with_venue_tbd = @workshops.where(:venue_id => nil)
      @workshops = @workshops.by_distance_from(@location)
      @other_workshops = Workshop.where(%Q(#{Workshop.quoted_table_column(:id)} NOT IN (#{@workshops.select(Workshop.quoted_table_column(:id)).to_sql})))
        .where(%Q(#{Workshop.quoted_table_column(:id)} NOT IN (#{@scheduled_workshops_with_venue_tbd.select(Workshop.quoted_table_column(:id)).to_sql})))
    else
      @other_workshops = Workshop.where(%Q(#{Workshop.quoted_table_column(:id)} NOT IN (#{@workshops.select(Workshop.quoted_table_column(:id)).to_sql})))
    end
    @workshops = @workshops.order(%Q(#{Meeting.quoted_table_column(:start_time)}))
  end

  def about
  end
end
