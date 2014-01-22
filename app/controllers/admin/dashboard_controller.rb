class Admin::DashboardController < ApplicationController
  def index
    dash_auth! :index, :dashboard
    set_activities_n_counts(20)
  end
  
  def recent_activity
    dash_auth! :recent_activity, :dashboard
    set_activities_n_counts
  end
  
  protected
  def set_activities_n_counts(n=ACTIVITIES_PER_PAGE)
    @activities_n_counts = Activity.activities_n_counts(n)
  end
  
  def dash_auth!(action, subject)
    authorize! action, subject, :message => "The admin dashboard is only for admins in admin mode."
  end
  
end
