class PagesController < ApplicationController
  def home
    # FIXME: this isn't cheap; maybe cache it or move more of it into a fancy SQL query
    @events = Workshop.future.ordered_by_earliest_meeting_start_time.map(&:next_rerun)
  end

  def about
  end
end
