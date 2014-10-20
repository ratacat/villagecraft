class CommentsController < ApplicationController
  
  load_and_authorize_resource(:find_by => :uuid, :param_method => :comment_params)
 
  def create
    # @comment = @parent.comments.build(params[:comment])
    @commentable = find_commentable
    # @comment = Comment.build(commentable_id: @commentable.id, commentable_type: params[:commentable_type], body: params[:body], user_id: current_user.id)
    @comment = @commentable.comments.build(user_id: current_user.id, 
                                           body: params[:comment][:body], 
                                           commentable_type: params[:comment][:commentable_type],
                                           commentable_id: @commentable.id)
    respond_to do |format|
      if @comment.save
        format.html { render :partial => 'comments/comment', :locals => {:comment => @comment } }
      else
        format.js { render :json => { :errors => @comment.errors.full_messages, :message => "Problem submitting comment" }, :status => :unprocessable_entity }
      end
    end
  end

private
  
  def comment_params
    params[:comment].permit([:body, :commentable_uuid, :commentable_type])
  end

  def find_commentable
    params[:comment][:commentable_type].constantize.find_by_uuid(params[:comment][:commentable_uuid])
  end

  # def load_parent
  #   # @event = Event.find(params[:event_id])  
  #   @parent = Event.find_by_id(params[:comment][:id] ) if params[:comment][:id] 
  #   @parent = Comment.find_by_id(params[:comment_id]) if params[:comment_id]
  #   # binding.pry
  #   # redirect_to root_path unless defined?(@parent)
  # end

end
