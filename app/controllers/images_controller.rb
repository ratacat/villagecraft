class ImagesController < ApplicationController
  load_and_authorize_resource(:find_by => :uuid)
  
  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    unless Rails.env.production?
      raise "Don't delete photos in dev; the AWS S3 images might be removed"
    end
    @image.destroy
    @image.create_activity :destroy, owner: current_user
    
    respond_to do |format|
      format.html { redirect_to @image.apropos, notice: "Photo deleted" }
      format.json { head :no_content }
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
    redirect_to polymorphic_url(@image.apropos, image_uuid: @image.uuid)
  end 
  
end
