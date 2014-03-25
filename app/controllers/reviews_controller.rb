class ReviewsController < ApplicationController

  load_and_authorize_resource(:find_by => :seod_uuid)


  def new
  end

  def create
    @review = Review.new(review_params)
    #@review.body = params[:body]
    @review.author = current_user
    workshop = Workshop.find_by_id(@review.apropos_id)

    if current_user.attended_workshop?(workshop)
      #get the last event the user attended
      @review.apropos = current_user.get_last_attended_event_by_workshop(workshop)
    else
      @review.apropos = workshop
    end
    respond_to do |format|
      if @review.save
        @review.create_activity :added, owner: current_user
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
      if @review.plus_rating(current_user)
         form.json { render json: @review, status: :ok}
      else
        form.json { render json: @review.errors.full_messages.first, status: :unprocessable_entity}
      end
    end
  end

  def minus
    #@review = Review.find_by_uuid(params[:id])
    respond_to do |form|
      if @review.minus_rating(current_user)
        form.json { render json: @review, status: :ok}
      else
        form.json { render json: @review.errors.full_messages.first, status: :unprocessable_entity}
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
    params[:review].permit(:body, :apropos_id)
  end
end
