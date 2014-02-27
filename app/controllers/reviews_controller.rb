class ReviewsController < ApplicationController
  def new
  end

  def create

    @review = Review.new(review_params)
    @review.author = current_user
    respond_to do |format|
      if @review.save
        flash[:success] = 'Review added!'
        format.html { redirect_to @review.event.workshop, notice: flash }
        format.json { render json: flash}
      else
        format.html { render json: @review.errors }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end


  end

  def destroy

  end

  def index

  end


  private
  def review_params
    params.require(:review).permit(:title, :body, :event_id)
  end
end
