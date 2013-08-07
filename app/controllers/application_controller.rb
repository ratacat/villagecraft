class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :fetch_notifications
  after_filter :store_location

  def store_location
    # store last url as long as it isn't a /users path
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end
  
  protected
  def render_error(options={})
    respond_to do |format|
      format.js { render :partial => 'layouts/update_alerts', :locals => {:alert => options[:message] }, :status => options[:status] }
      format.html { redirect_to root_path, :alert => options[:message] }
      format.json { render :json => { :message => options[:message] }, :status => options[:status] }
    end
  end
  
  def require_admin
    unless user_signed_in? and current_user.admin? # and admin mode enabled FIXME
      render_error(:message => "Administrative access required", :status => :unauthorized)
    end    
  end
  
  def fetch_notifications
    if user_signed_in?
      @notifications = current_user.notifications.order('created_at desc').limit(10)
      @unseen_notifications_count = current_user.notifications.where(:seen => false).count
    end
  end
    
end
