class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      if @user.save
        flash[:notice] = ["Welcome to Villagecraft"]
        # FIXME: session[:auto_attend_event] cookie not sent; I think this has to do with the window.location= hack in _facebook.js.erb; 
        # for now, rely on params[:auto_attend_event]; grrr.
        if (m = /^\/events\/(?<event_uuid>\w+)$/.match(session[:previous_url])) and params[:auto_attend_event]
          @event = Event.find_by_uuid(m[:event_uuid])
          @user.attends << @event
          flash[:notice] << 'You are signed up to attend this event'
        end
        sign_in_and_redirect @user, :event => :authentication
      else
        flash[:alert] = "Could not complete your sign up via Facebook."
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
      
    end
  end
end
