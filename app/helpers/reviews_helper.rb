module ReviewsHelper
  def get_rating_with_sign(rating)
    if rating > 0
      "+#{rating}"
    else
      rating
    end
  end
end
