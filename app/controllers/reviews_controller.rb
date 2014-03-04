class ReviewsController < ApplicationController

  load_and_authorize_resource(:find_by => :seod_uuid)


  def new
  end

  def create
    @review = Review.new(review_params)
    @review.author = current_user
    respond_to do |format|
      if @review.save
        flash[:success] = 'Review added!'
        format.html { redirect_to @review.event.workshop, notice: flash }
        format.json { render json: flash, status: :created}
      else
        format.html { render json: @review.errors }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def plus
    #@review = Review.find_by_uuid(params[:id])
    respond_to do |form|
      if @review.plus_rating(current_user.id)
         form.json { render json: @review, status: :ok}
      else
        form.json { render json: @review.errors, status: :unprocessable_entity}
      end
    end
  end

  def minus
    #@review = Review.find_by_uuid(params[:id])
    respond_to do |form|
      if @review.minus_rating(current_user.id)
        form.json { render json: @review, status: :ok}
      else
        form.json { render json: @review.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    respond_to do |format|
      if @review.destroy
        flash[:success] = 'Review deleted!'
        format.json { render json: flash, status: :ok}
      else
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @review = Review.new
    @reviews = Review.return_reviews_by_user(current_user).sort_by(&:created_at).reverse
    @unreviewed_events = Review.return_unreviewed_events_by_user(current_user)
  end


  private
  def review_params
    #params.require(:review).permit(:title, :body, :event_id)
    params[:review].permit(:body, :event_id)
  end
end
