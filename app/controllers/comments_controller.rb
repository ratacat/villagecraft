class CommentsController < ApplicationController
  before_filter :load_event

  def index
    @comments = @event.comments.all
    @user = current_user
  end

  def create  
    @comment = @event.comments.new comment_params
    @comment.user_id = current_user.id
    if @comment.save
      redirect_to event_path(@event)
    else
      render 'new'
    end
  end
    
private
  
  def comment_params
    params.require(:comment).permit(:body)
  end

  def load_event
    @event = Event.find(params[:comment][:id])
  end

end
