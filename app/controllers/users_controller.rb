class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]
  before_filter :require_admin, :if => lambda {|c| c.is_a?(Admin::UsersController) }
  skip_before_filter :possibly_nag_for_phone, only: [:edit_settings]

  load_and_authorize_resource(:find_by => :uuid, :param_method => :user_params)
  
  # GET /users
  # GET /users.json
  def index
    @users = User.order(:created_at).reverse_order

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @workshops = Workshop.where(:host_id => @user).first_meeting_in_the_future
    @other_workshops = Workshop.where(:host_id => @user).where(%Q(#{Workshop.quoted_table_column(:id)} NOT IN (#{@workshops.select(Workshop.quoted_table_column(:id)).to_sql})))
    @workshops = @workshops.order(%Q(#{Meeting.quoted_table_column(:start_time)}))
    @workshops = @workshops.to_a.uniq
    @sort_order = 'date'
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
  end

  # GET /settings
  def edit_settings
    unless admin_session? and @user
      @user = current_user
    end
  end

  # PUT /update_settings
  def update_settings
    unless admin_session? and @user
      @user = current_user
    end
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { 
          if admin_session? and @user != current_user
            redirect_to edit_settings_path(@user), notice: "#{@user.possessable_name.possessive.capitalize} settings have been updated."
          else
            redirect_to edit_settings_path, notice: 'Your settings have been updated.'
          end
        }
        format.json { head :no_content }
      else
        format.html { render action: "edit_settings" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  # GET /users/hostify_me
  def hostify_me
    hostify_admin = User.find_by_email("hostify@villagecraft.org")
    @message = Message.new(:from_user => current_user, :to_user => hostify_admin, :subject => "Host Interest from #{current_user.name} <#{current_user.email}>")
  end
  
  protected
  def find_user
    begin
      @user = User.find_by_uuid(params["id"])
    rescue Exception => e
    end
    render_error(:message => "User not found.", :status => 404) if @user.blank?
  end  
  
  def be_user_or_be_admin
    unless (current_user == @user or admin_session?)
      render_error(:message => "You are not authorized to access this information.", :status => :unauthorized)
    end
  end
  
  def user_params
    ok_params = [:email, :password, :remember_me, :name, :city, :state, :profile_image, :location, :has_set_password, :phone, :email_notifications, :sms_short_messages, :email_short_messages, :preferred_distance_units, :email_system_messages]
    ok_params += [:host, :external, :promote_host] if admin_session?
    ok_params += [:description] if current_user.host?
    params[:user].permit(*ok_params)
  end
end
