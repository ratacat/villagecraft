class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication # this will throw if @user is not activated; it will also save the @user, persisting the @user.auth_provider and @user.auth_provider_uid in the case that the FB identity was merged into an existing user account
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      auto_attend
    else
      if @user.save
        flash[:notice] = ["Welcome to Villagecraft"]
        auto_attend
        sign_in_and_redirect @user, :event => :authentication
        @mixpanel.track(@user.email, 'Registration', {
          'source' => "facebook",
          'modal' => "false",
          'date' => I18n.t @user.created_at, format: :short_time
        })
      else
        flash[:alert] = "Could not complete your sign up via Facebook."
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
      
    end
  end
  
  protected
  def auto_attend
    # FIXME: session[:auto_attend_event] cookie not sent; I think this has to do with the window.location= hack in _facebook.js.erb; 
    # for now, rely on params[:auto_attend_event]; grrr.
    if (m = /^\/events\/(?<event_uuid>\w+)$/.match(session[:previous_url])) and params[:auto_attend_event]
      @event = Event.find_by_uuid(m[:event_uuid])
      @user.attends << @event
      flash[:notice] = [flash[:notice]] unless flash[:notice].is_a?(Array)
      flash[:notice] << 'You are now signed up for this event'
    end    
  end
end
