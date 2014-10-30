class Admin::DashboardController < ApplicationController
  before_filter { |controller| authorize! :foobar, :dashboard, :message => "The admin dashboard is only for admins in admin mode." }
  def index
    set_activities_n_counts(20)
  end
  
  def recent_activity
    set_activities_n_counts
  end
  
  def send_system_mailing
    @message = Message.where(:system_message => true).order(:created_at).last
    @message ||= Message.new(body: "<make a newsy letter here>")
  end
  
  protected
  def set_activities_n_counts(n=ACTIVITIES_PER_PAGE)
    @activities_n_counts = Activity.activities_n_counts(:limit => n)
  end
  
end
