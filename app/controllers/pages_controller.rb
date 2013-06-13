class PagesController < ApplicationController
  def home
    @events = Event.order('start_time DESC')
  end

  def about
  end
end
