class ActivitiesController < ApplicationController
  def fetch
    ids = params[:ids]

    if ids.size > 200
      render_error(:message => 'Too many activity recrods requested', :status => :unauthorized)
    else
      @activities = PublicActivity::Activity.where(:id => ids).order(:id).reverse_order
      render :partial => 'activities/index', :locals => {:activities_n_counts => @activities}
    end
  end
end
