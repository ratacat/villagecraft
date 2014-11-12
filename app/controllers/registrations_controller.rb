class RegistrationsController < Devise::RegistrationsController

  def create
    Rails.logger.info params.inspect
    unless params[:user][:password].present?
      random_pwd = Devise.friendly_token[0,20]
      params[:user][:password] = random_pwd
    end
    super

    user = User.find_by_email(params[:user][:email])
  end

end
