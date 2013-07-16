class RegistrationsController < Devise::RegistrationsController
  def update
    @user = User.find(current_user.id)

    password_present = params[:user][:password].present?
    
    successfully_updated = if @user.has_set_password
      @user.update_with_password(params[:user])
    else
      params[:user].delete(:current_password)
      @user.update_attributes(params[:user])
    end

    if successfully_updated
      if password_present
        @user.update_attribute(:has_set_password, true)
      end
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

end
