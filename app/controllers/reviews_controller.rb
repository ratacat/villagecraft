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

  end

  def index

  end


  private
  def review_params
    #params.require(:review).permit(:title, :body, :event_id)
    params[:review].permit(:body, :event_id)
  end
end
