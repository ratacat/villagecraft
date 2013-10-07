class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_notification, :except => [:index]
  before_filter :be_user_or_be_admin, :only => [:show]
  
  NOTIFICATIONS_PER_PAGE = 50
  
  # GET /notifications(.:format)
  def index
    @notifications = current_user.notifications.order('created_at desc').limit(NOTIFICATIONS_PER_PAGE)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notifications }
    end
  end

  # GET /notification/1
  # GET /notification/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @notification }
    end
  end
  
  # POST / notifications/clear
  def clear
    Notification.where(:user_id => current_user).where(:seen => false).update_all(:seen => true)
    render :nothing => true, :status => 200
  end
  
  protected
  def find_notification
    @notification = Notification.find_by_uuid(params["id"])
    render_error(:message => "Notification (#{params["id"]}) not found.", :status => 404) if @notification.blank?
  end
  
  def be_user_or_be_admin
    unless (current_user == @notification.target or current_user.admin?)
      render_error(:message => "You are not authorized to access this notification.", :status => :unauthorized)
    end
  end
  
end
