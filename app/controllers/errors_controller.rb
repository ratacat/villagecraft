class ErrorsController < ApplicationController
  def not_found
    flash.now[:error] = "Page not found."
    render :status => 404, :formats => [:html]
  end

  def server_error
    flash.now[:error] = "Uh oh, something went wrong. Our crack team of crafty crafters has been notified."
    render :status => 500, :formats => [:html]
  end
end
