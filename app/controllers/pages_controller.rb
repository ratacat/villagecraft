class PagesController < ApplicationController
  def home
    # FIXME: this isn't cheap; maybe cache it or move more of it into a fancy SQL query
    @workshops_with_upcoming_or_ongoing_reruns = Workshop.joins(:first_meetings).where(%Q(#{Meeting.quoted_table_column(:end_time)} > ?), Time.now).order(%Q(#{Meeting.quoted_table_column(:start_time)})).to_a.uniq
    @workshops = (@workshops_with_upcoming_or_ongoing_reruns + Workshop.where("id NOT IN (?)", @workshops_with_upcoming_or_ongoing_reruns))
  end

  def about
  end
end
