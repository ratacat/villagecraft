class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def render_error(options={})
    respond_to do |format|
      format.js { render :partial => 'layouts/update_alerts', :locals => {:alert => options[:message] } }
      format.html { redirect_to root_path, :alert => options[:message] }
      format.json { render :json => { :message => options[:message] }, :status => options[:status] }
    end
  end
  
end
