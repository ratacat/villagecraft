class Review < ActiveRecord::Base
  attr_accessible :body, :event_id, :rating, :title, :author

  acts_as_paranoid

  belongs_to :event
  belongs_to :author, :class_name => 'User'

  validates :title, :presence => true
  validates :body, :presence => true
  validates :event_id, :presence => true
  validates :event_id, :uniqueness => { :scope => [:author_id], :message => "You have already reviewed this." }
  #validates_uniqueness_of :event_id, scope: [:author_id]
  validates :author, :presence => true

  before_create :set_rating


  def plus_rating(user_id)
    self.rating = self.rating + 1
    self.save
  end

  def minus_rating(user_id)
    self.rating = self.rating - 1
    self.save
  end


  class << self
    def return_all_reviews_by_workshop(workshop)
      reviews = []
      workshop.events.each do |event|
        event.reviews.each { |comm| reviews << comm}
      end
      reviews
    end

    def sort_reviews_by_created(reviews, limit = nil)
      sorted_reviews = reviews.sort_by(&:created_at).reverse
      sorted_reviews.take(limit) unless limit.blank?
    end

    def sort_reviews_by_rating(reviews, limit = nil)
      sorted_reviews = reviews.sort_by(&:rating).reverse
      sorted_reviews.take(limit) unless limit.blank?
    end

    def return_reviews_by_user(user)
      user.reviews.map { |comm| comm}
    end
  end
  #def Review.return_all_pending_events_to_review_by_workshop_and_user(workshop, user)
  #  events_to_review = []
  #  unless workshop.events.blank? && workshop.events.where_first_meeting_starts_in_past.to_a.blank?
  #    workshop.events.where_first_meeting_starts_in_past.to_a.each do |past_event|
  #      # first check if the user attended the event and if user did not review the event
  #      if Attendance.where(:event_id => past_event).where(:user_id => user).count == 1 && past_event.reviews.where(:author => user).count == 0
  #        events_to_review << past_event
  #      end
  #    end
  #  end
  #end


  private
  def set_rating
    self.rating = 0
  end
end
