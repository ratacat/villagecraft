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
    else
      @location = Location.find_or_create_by_address('Berkeley, CA')
    end
    q = Workshop.first_meeting_in_the_future
    if session[:sort_order] == 'distance'
      q = q.by_distance_from(@location)
    end
    q = q.order(%Q(#{Meeting.quoted_table_column(:start_time)}))
    @workshops_with_upcoming_or_ongoing_reruns = q
    @workshops = q.to_a.uniq
    @other_workshops = 
      if @workshops.blank?
        Workshop.all
      else      
        Workshop.where("id NOT IN (?)", @workshops)
      end
  end

  def about
  end
end
