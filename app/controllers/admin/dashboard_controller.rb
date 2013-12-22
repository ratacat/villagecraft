class Admin::DashboardController < ApplicationController
  def index
    authorize! :index, :dashboard, :message => "The admin dashboard is only for admins in admin mode."
  end
end
