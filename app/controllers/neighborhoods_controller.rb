class NeighborhoodsController < ApplicationController
  load_and_authorize_resource
  
  # GET /neighborhoods
  # GET /neighborhoods.json
  def index
    @neighborhoods = Neighborhood.all(:order => 'state, city')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @neighborhoods }
    end
  end

  # GET /neighborhoods/1
  # GET /neighborhoods/1.json
  def show
    @neighborhood = Neighborhood.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @neighborhood }
    end
  end
  
  # GET /neighborhoods/1/edit
  def edit
  end

  # PUT /neighborhoods/1
  # PUT /neighborhoods/1.json
  def update
    respond_to do |format|
      if @neighborhood.update_attributes(params[:neighborhood])
        format.html { redirect_to @neighborhood, notice: 'Neighborhood was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @neighborhood.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /neighborhoods/1
  # DELETE /neighborhoods/1.json
  def destroy
    @neighborhood.destroy

    respond_to do |format|
      format.html { redirect_to neighborhoods_url }
      format.json { head :no_content }
    end
  end
  

end
