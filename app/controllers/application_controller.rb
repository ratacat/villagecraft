class ApplicationController < ActionController::Base
  include PublicActivity::StoreController
  
  protect_from_forgery
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :authenticate_user_from_token!  # from https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
#  before_filter :fetch_notifications
  before_filter :possibly_nag_for_phone
  after_filter :store_location, :except => [:attend_by_email]
  before_filter :set_mixpanel
  before_filter :uuid_cookie

  ACTIVITIES_PER_PAGE = 100

  def store_location
    # store last url as long as it isn't a /users path
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/
  end

  def after_sign_in_path_for(resource)
    if cookies[:auto_attend_event]
      if cookies[:auto_attend_event] =~ /^_HOSTIFY_ME_/
        cookies.delete :auto_attend_event
        hostify_me_users_path
      else
        @event = Event.find_by_uuid(cookies[:auto_attend_event])
        cookies.delete :auto_attend_event
        if @event
          @user.attends << @event
          @event.create_activity key: 'event.interested', owner: @user            
          event_path(@event)
        else
          root_path
        end
      end
    else
      session[:previous_url] || root_path
    end
    
  end
  
  def current_ability
    @current_ability ||= Ability.new(current_user, session)
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.js { render :json => { :errors => [exception.message], :message => "Access denied" }, :status => :forbidden }
      format.html {
        if exception.message =~ /sign up/
          redirect_to new_user_registration_path, :alert => exception.message 
        else
          redirect_to root_url, :alert => exception.message 
        end
      }
      format.json { render :inline => exception.message, :status => :forbidden }
    end
  end
  
  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.js { render :json => { :errors => [exception.message], :message => "Not found" }, :status => 404 }
      format.html { redirect_to root_url, :alert => exception.message }
      format.json { render :inline => exception.message, :status => 404 }
    end
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
  
  def fetch_notifications
    if user_signed_in?
      @notifications = current_user.notifications.order('created_at desc').limit(10)
      @unseen_notifications_count = current_user.notifications.where(:seen_at => nil).count
    end
  end
  
  def be_host_or_be_admin(obj)
    unless user_signed_in? and (current_user == obj.host or admin_session?)
      render_error(:message => "You must be the #{obj.class.to_s.downcase}'s host or an admin to do that.", :status => :unauthorized)
      return false
    end
    return true
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:sign_up) << :phone
  end
  
  def possibly_nag_for_phone
    if user_signed_in? and current_user.phone.blank?
      flash.now[:warning] = "To receive notifications of last-minute changes to workshops you are attendings, #{view_context.link_to('edit your settings', edit_settings_path)} to include a mobile number.".html_safe
    end
  end

  def set_mixpanel
    #tracker is used to send pushes
    @mixpanel = Mixpanel::Tracker.new(MIXPANEL[:token])
  end
  
  # token_authenticatable was removed from devise 3; this is Jose Valim's suggestion for adding it back in in a secure way (see: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6)
  private
  # For this example, we are simply using token authentication
  # via parameters. However, anyone could use Rails's token
  # authentication features to get the token from a header.
  
  # FIXME: consider getting paranoid about timing attacks and requiring email + auth_token and using secure_compare per Jose Valim's suggestion in the gist and here:
  # http://blog.plataformatec.com.br/2013/08/devise-3-1-now-with-more-secure-defaults/
  def authenticate_user_from_token!
    user_token = params[:auth_token].presence
    user       = user_token && User.find_by_authentication_token(user_token.to_s)
 
    if user
      # Notice we are passing store false, so the user is not
      # actually stored in the session and a token is needed
      # for every request. If you want the token to work as a
      # sign in token, you can simply remove store: false.
      sign_in user, store: false
    end
  end

  def uuid_cookie
    if user_signed_in? && (cookies[:uuids] == nil)
      @uuids = []
      @uuids.push(current_user.uuid)
      cookies.permanent[:uuids] = @uuids.to_json
    elsif user_signed_in? && cookies[:uuids].present?
      @uuids = JSON.parse(cookies[:uuids])
      unless @uuids.include?(current_user.uuid)
        @uuids.push(current_user.uuid)
        cookies.permanent[:uuids] = @uuids.to_json
      end
    end
    # binding.pry
  end
end
