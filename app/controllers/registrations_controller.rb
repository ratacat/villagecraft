class RegistrationsController < Devise::RegistrationsController

  def create
    unless params[:user][:password].present?
      random_pwd = Devise.friendly_token[0,20]
      params[:user][:password] = random_pwd
    end
    super
  end

end
