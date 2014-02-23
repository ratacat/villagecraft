class MessagesController < ApplicationController
  load_and_authorize_resource(:find_by => :uuid)
  
  # GET /messages
  # GET /messages.json
  def index
    @messages = message.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = message.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])
    @message.from_user = current_user
    
    respond_to do |format|
      if @message.save
        case @message.apropos
        when Event
          @message.apropos.create_activity(key: 'event.email', owner: current_user, parameters: {:uuid => @message.uuid})
        end
        format.js { render :refresh_messages_select }
        format.html { redirect_to @message, notice: 'message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.js { render :json => { :errors => @message.errors.full_messages, :message => "Problem creating new message" }, :status => :unprocessable_entity }
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  
end