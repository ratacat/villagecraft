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
    @message = Message.new(params[:message])
    @message.send(:find_apropos)
    @message.send(:find_to_user)
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])
    if admin_session? and (not @message.to_user) and (not @message.system_message?)
      @message.send(:find_apropos)
      @message.from_user = @message.apropos.host
    else
      @message.from_user = current_user  # important! Message#sender_authorized_to_send? depends on this being set correctly
    end

    respond_to do |format|
      if @message.save
        unless @message.to_user
          case @message.apropos
          when Event
            @message.apropos.create_activity(key: 'event.email', owner: current_user, parameters: {:uuid => @message.uuid})
          end
        end
        format.html { redirect_to root_url, notice: 'Your message has been sent.' }
        format.json { render json: {}, status: :created, location: @message }
      else
        format.js { render :json => { :errors => @message.errors.full_messages, :message => "Problem creating new message" }, :status => :unprocessable_entity }
        format.html { render_error(:message => "Trouble saving message.", :status => 403) }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  
end
