class Review < ActiveRecord::Base

  attr_accessible :body, :event_id, :rating, :title, :author
  has_uuid(:length => 8)
  #acts_as_paranoid

  belongs_to :event
  has_one :workshop, :through => :event
  belongs_to :author, :class_name => 'User'

  has_many :ratings

  #validates :title, :presence => true
  validates :body, :presence => true, :blacklist => true, :length => {
                                                                    :minimum   => 12,
                                                                    :maximum   => 4000,
                                                                    :tokenizer => lambda { |str| str.scan(/\s+|$/) },
                                                                    :too_short => "Must have at least %{count} words",
                                                                    :too_long  => "Must have at most %{count} words"}
  validates :event_id, :presence => true, :uniqueness => { :scope => [:author_id], :message => "You have already reviewed this." }

  validates :author, :presence => true

  before_create :set_rating


  def plus_rating(user)
    transaction do
      self.rating = self.rating + 1
      rating = Rating.create_rating(self, user)
      if rating.save
        self.save
      else
        self.errors.add(:rating, "has been already provided for this review by you")
        false
      end
    end
  end

  def minus_rating(user)
    transaction do
      self.rating = self.rating - 1
      rating = Rating.create_rating(self, user)
      if rating.save
        self.save
      else
        self.errors.add(:rating, "has been already provided for this review by you")
        false
      end
    end
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

    def find_by_seod_uuid!(id)
      self.find_by_uuid!(id.split('-').first)
    end

    def return_unreviewed_events_by_user(user)
      returned_events = []
      user.get_all_attended_events.each do |event|
        if event.reviews.where(:author_id => user).count == 0
          returned_events << event
        end
      end
      returned_events
    end
  end


  private
  def set_rating
    self.rating = 0
  end
end
