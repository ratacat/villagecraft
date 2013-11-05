class PagesController < ApplicationController
  def home
    @events = Event.ending_after(Time.now).order('start_time')
  end

  def about
  end
end
