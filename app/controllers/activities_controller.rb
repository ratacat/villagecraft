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
  
  def more
    id_lower_than = params[:id_lower_than]
    @activities_n_counts = Activity.activities_n_counts(:limit => ACTIVITIES_PER_PAGE, :id_lower_than => id_lower_than)
    render :partial => 'activities/index', :locals => {:activities_n_counts => @activities_n_counts}
  end
end
