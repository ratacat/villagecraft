class ImagesController < ApplicationController
  load_and_authorize_resource(:find_by => :uuid)
  
  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Photo deleted" }
      format.json { head :no_content }
    end
  end
  
  
end
