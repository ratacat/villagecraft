class SessionsController < ApplicationController
  before_filter :require_adminable

  def admin_mode_toggle
    if session[:admin_mode]
      session[:admin_mode] = nil
      redirect_to root_path, :alert => "You have left admin mode and are again just a normal user."
    else
      session[:admin_mode] = true
      redirect_to admin_path, :alert => "Admin mode enabled for this session."      
    end
  end

  
  protected
  def require_adminable
    unless current_user.try(:admin?)
      render_error(:message => "You do not have the privileges to enter admin mode.", :status => :unauthorized)
    end    
  end

end
