class OrganizationsController < ApplicationController

  def create
    @organization = Organization.where("name ilike ?", params[:organization][:name]).limit(1).first

    respond_to do |format|
      if @organization.blank?
        @organization = Organization.new(params[:organization])
        if @organization.save
          format.json { render json: {id: @organization.id}, status: :ok, location: url_for(@organization)}
        else
          format.json { render json: @organization.errors, status: :unprocessable_entity}
        end
      else
        format.json { render json: {id: @organization.id}, status: :ok, location: url_for(@organization)}
      end
    end
  end

  def show
    @organization = Organization.find(params[:id])
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def autocomplete
    @organizations = Organization.where("name ilike ?", "%#{params[:organization][:name]}%")
    respond_to do |format|
      format.json { render json: @organizations }
    end
  end
end
