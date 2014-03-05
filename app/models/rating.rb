class Rating < ActiveRecord::Base
  attr_accessible :rater_id, :review_id

  belongs_to :rater, :class_name => 'User'
  belongs_to :review

  validates :rater_id, :presence => true
  validates :review_id, :presence => true,  :uniqueness => {:scope => :rater_id, :message => "has been already rated by you"}


  class << self

    def create_rating(review, user)
      rating = Rating.new
      rating.rater = user
      rating.review = review
      unless rating.save
        "has been already rated by you"
      end
    end
  end
end
