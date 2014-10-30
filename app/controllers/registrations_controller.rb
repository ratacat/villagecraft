class RegistrationsController < Devise::RegistrationsController

  def create
    Rails.logger.info params.inspect
    unless params[:user][:password].present?
      random_pwd = Devise.friendly_token[0,20]
      params[:user][:password] = random_pwd
    end
    super

    user = User.find_by_email(params[:user][:email])
    # distinct_id = cookies[:mp_cd5f1afe1374c3c354a379627be6c27d_mixpanel].gsub(/"(.*)":\s"(.*)","(.*)":\s"(.*)","(.*)":\s"(.*)"/, '\2').gsub(/[\{\}]/, '')

<<<<<<< HEAD
    # if user
    #   @mixpanel.alias(user.email, distinct_id)
    #   @mixpanel.track(user.email, 'Registration', {
    #       'source' => "villagecraft",
    #       'modal' => params[:user][:modal]
    #   })

    #   @mixpanel.people.set(user.email, {'$name' => user.name, 'account_created_at' => DateTime.now}, request.remote_ip)
    # end
=======
    if user
      begin
      @mixpanel.alias(user.email, distinct_id)
      @mixpanel.track(user.email, 'Registration', {
          'source' => "villagecraft",
          'modal' => params[:user][:modal]
      })

      @mixpanel.people.set(user.email, {'$name' => user.name, 'account_created_at' => DateTime.now}, request.remote_ip)
      rescue => error
        puts error.message
      end
    end
>>>>>>> c006cf5d637fdc9c38c059242ac078d3d5f75df5
    
  end

end
