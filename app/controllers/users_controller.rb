class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]
  before_filter :require_admin, :if => lambda {|c| c.is_a?(Admin::UsersController) }

  # hacky inter-op between cancan and strong_parameters (see: https://github.com/ryanb/cancan/issues/571); FIXME: when we upgrade to Rails 4
  before_filter do
    params[:user] &&= user_params
  end
  load_and_authorize_resource(:find_by => :uuid)
  
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
  end

  # GET /preferences
  def edit_preferences
    @user = current_user
  end

  # PUT /update_preferences
  def update_preferences
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to root_path, notice: 'Your preferences have been updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit_preferences" }
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
    ok_params = [:email, :password, :remember_me, :name, :city, :state, :profile_image, :location, :has_set_password, :phone, :email_notifications]
    ok_params += [:host, :external] if admin_session?
    params[:user].permit(*ok_params)
  end
end
