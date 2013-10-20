class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :sign_in_if_auth_token
  before_filter :fetch_notifications
  after_filter :store_location
  before_filter :require_admin, :only => [:dash]

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
  
  def admin_session?
    current_user.try(:admin?) and session[:admin_mode]
  end
  helper_method :admin_session?
  
  def require_admin
    unless admin_session?
      render_error(:message => "Administrative access and admin mode required", :status => :unauthorized)
    end
  end
  
  def require_host
    unless current_user.try(:host?)
      render_error(:message => "Host privileges required", :status => :unauthorized)
    end
  end
  
  def sign_in_if_auth_token
    if params[:authentication_key].present?
      @user = User.find_by_authentication_token(params[:authentication_key])
      sign_in @user if @user
      redirect_to root_path
    end
  end
    
  def fetch_notifications
    if user_signed_in?
      @notifications = current_user.notifications.order('created_at desc').limit(10)
      @unseen_notifications_count = current_user.notifications.where(:seen => false).count
    end
  end
    
end
