class Admin::DashboardController < ApplicationController
  def index
    dash_auth! :index, :dashboard
  end
  
  def recent_activity
    dash_auth! :recent_activity, :dashboard
    @activities = PublicActivity::Activity.order(:created_at).reverse_order.limit(ACTIVITIES_PER_PAGE)
  end
  
  protected
  
  def dash_auth!(action, subject)
    authorize! action, subject, :message => "The admin dashboard is only for admins in admin mode."
  end
  
end
