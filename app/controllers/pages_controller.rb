class PagesController < ApplicationController
  def home
    @events = Event.future.order('start_time')
  end

  def about
  end
end
