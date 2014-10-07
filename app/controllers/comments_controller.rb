class CommentsController < ApplicationController
  
  load_and_authorize_resource(:find_by => :uuid, :param_method => :comment_params)
 
  def create
    # @comment = @parent.comments.build(params[:comment])
    @commentable = find_commentable
    @comment = @commentable.comments.build(params[:comment])
    @comment.user_id = current_user.id 
    respond_to do |format|
      if @comment.save
        # format.html { redirect_to event_path(@parent), notice: 'Comment was successfully created.' }
        format.html { redirect_to @commentable, notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created }
        # format.js {render partial:"create"}
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

private
  
  def comment_params
    params.permit([:body, :commentable_uuid, :commentable_type])
  end

  def find_commentable
    params[:commentable_type].constantize.find_by_uuid(params[:commentable_uuid])
  end

  # def load_parent
  #   # @event = Event.find(params[:event_id])  
  #   @parent = Event.find_by_id(params[:comment][:id] ) if params[:comment][:id] 
  #   @parent = Comment.find_by_id(params[:comment_id]) if params[:comment_id]
  #   # binding.pry
  #   # redirect_to root_path unless defined?(@parent)
  # end

end
