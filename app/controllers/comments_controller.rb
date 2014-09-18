class CommentsController < ApplicationController
  # before_filter :load_parent

  def index
    # @comments = @parent.comments.all
    @commentable = find_commentable
    @comments = @commentable.comments
  end

  def new  
    # @comment = @parent.comments.new 
    @parent_id = params.delete(:parent_id)
    @commentable = find_commentable
    @comment = Comment.new( :parent_id => @parent_id,
                            :commentable_id => @commentable.id,
                            :commentable_type => @commentable.class.to_s)
  end
 
  def create   
    # @comment = @parent.comments.new(comment_params)
    @commentable = find_commentable
    @comment = @commentable.comments.build(params[:comment])
    @comment.user_id = current_user.id 
    respond_to do |format|
      # binding.pry
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
    

protected 
  # def comment_params
  #   params.require(:comment).permit(:id, :body, :parent_id, :commentable_id, :commentable_type)
  # end

  # def load_parent
  #  @parent = Event.find(params[:comment][:id]) if params[:comment][:id]
  #  @parent = Comment.find(params[:comment_id]) if params[:comment_id]
  # end

  def find_commentable
    @commentable = Event.find(params[:comment][:id]) if params[:comment][:id]
    @commentable = Comment.find(params[:comment_id]) if params[:comment_id]
  #   params.each do |name, value|
  #     if name =~ /(.+)_id$/
  #       return $1.classify.constantize.find(value)
  #     end
  #   end
  #   nil
  end

end
