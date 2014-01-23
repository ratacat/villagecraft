class ActivitiesController < ApplicationController
  def fetch_range
    min = params[:min].to_i
    max = params[:max].to_i
    
    if max - min > 200
      render_error(:message => 'Too many activity recrods requested', :status => :unauthorized)
    else
      @activities = PublicActivity::Activity.where(:id => (min..max)).order(:id).reverse_order
      render :partial => 'activities/index', :locals => {:activities_n_counts => @activities}
    end
  end
end
