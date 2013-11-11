class PagesController < ApplicationController
  def home
    @events = Event.future.ordered_by_earliest_start_time
  end

  def about
  end
end
