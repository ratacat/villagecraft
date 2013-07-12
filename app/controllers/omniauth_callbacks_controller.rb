class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      fb_info = request.env["omniauth.auth"][:info]
      user = User.new(fb_info.slice(:email, :first_name, :last_name), without_protection: true)

      # FIXME: do something to verify that location is in US
      user.location = Location.find_or_create_by_address(fb_info[:location])
      user.location.reverse_geocode
      user.location.save
            
      user.password = user.password_confirmation = rand(36**30).to_s(36)

      if user.save
        flash[:notice] = "Welcome to Villagecraft"
        sign_in_and_redirect user, :event => :authentication
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url        
      end
      
    end
  end
end
