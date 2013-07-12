class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      fb_info = request.env["omniauth.auth"][:info]
      user = User.new(fb_info.slice(:email, :first_name, :last_name), without_protection: true)

      l = Location.new(:address => fb_info[:location])
      l.geocode
      l.reverse_geocode
      user.city = l.city
      user.state = l.state_code
            
      user.password = user.password_confirmation = rand(36**30).to_s(36)

      if user.save
        flash[:notice] = "Successful sign-in via Facebook"
        sign_in_and_redirect user, :event => :authentication
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url        
      end
      
    end
  end
end
