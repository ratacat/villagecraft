class RegistrationsController < Devise::RegistrationsController
  after_filter :check_for_auto_attend 

  def create
    unless params[:user][:password].present?
      random_pwd = Devise.friendly_token[0,20]
      params[:user][:password] = random_pwd
    end
    super
  end

  protected
  def check_for_auto_attend
    if resource.persisted? # user is created successfuly
      if cookies[:auto_attend_event]
        # check for hostify_me pseudo event uuid
        if cookies[:auto_attend_event] =~ /^_HOSTIFY_ME_/
          Message.new_hostify_msg(:from_user => @user)
          flash[:notice] = "Thanks for your interest in becomming a Villagecraft host.  We'll be in touch!"
        else
          @event = Event.find_by_uuid(cookies[:auto_attend_event])
          @user.attends << @event
          @event.create_activity key: 'event.interested', owner: @user
        end
        cookies.delete :auto_attend_event
      end
    end
  end

end
