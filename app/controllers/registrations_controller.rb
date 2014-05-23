class RegistrationsController < Devise::RegistrationsController

  def create
    Rails.logger.info params.inspect
    unless params[:user][:password].present?
      random_pwd = Devise.friendly_token[0,20]
      params[:user][:password] = random_pwd
    end
    super

    user = User.find_by_email(params[:user][:email])

    if user
      @mixpanel.track(user.email, 'Registration', {
          'source' => "villagecraft",
          'modal' => params[:user][:modal]
      })
    end
  end

end
