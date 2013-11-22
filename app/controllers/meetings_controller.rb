class MeetingsController < ApplicationController
  load_and_authorize_resource(:find_by => :uuid)
  before_filter :check_lock, :only => [:update]
  
  # PUT /meetings/1
  # PUT /meetings/1.json
  def update
    respond_to do |format|
      if @meeting.update_attributes(params[:meeting])
        format.js { head :no_content }
        format.html { redirect_to @meeting, notice: 'Meeting successfully updated.' }
        format.json { head :no_content }
      else
        format.js { render :json => { :errors => @meeting.errors.full_messages, :message => "Problem updating meeting" }, :status => :unprocessable_entity }
        format.html { render action: "edit" }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end
  
  protected
  def check_lock
    if @meeting.event.locked?
      raise CanCan::AccessDenied.new("Workshop locked (#{view_context.pluralize(@meeting.event.attendances.count, 'person')} attending)", action_name, Meeting)
    end
  end
  
end
