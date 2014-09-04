class CommentsController < ApplicationController
  before_filter :load_parent

  def index
    @comments = @parent.comments.all
  end

  def new
    @comment = @parent.comments.build
  end
 
  def create
    @comment = @parent.comments.build(params[:comment])
    @comment.user_id = current_user.id 
    respond_to do |format|
      if @comment.save
        format.html { redirect_to event_path(@parent), notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created }
        # format.js {render partial:"create"}
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end
    
protected
  
  # def comment_params
  #   params.require(:comment).permit(:body, :commentable_id, :commentable_type)
  # end

  def load_parent
    # @event = Event.find(params[:event_id])  
    @parent = Event.find_by_id(params[:comment][:id] ) if params[:comment][:id] 
    @parent = Comment.find_by_id(params[:comment_id]) if params[:comment_id]
    # redirect_to root_path unless defined?(@parent)
  end

end
