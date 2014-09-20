class ChargesController < ApplicationController

# POST /charges
  def create
    event = Event.find(params[:event_id])
    token = params[:stripeToken]
    amount = (event.price.to_i) * 100
    
    unless (fee = amount / 10) > 100        #set application fee to 10% or $1
      fee = 100
    end

    unless current_user.stripe_customer_id  #find user by stripe customer id
      customer = Stripe::Customer.create(   #or create new stripe customer 
        :card => token[:id],                #and set stripe customer id on user
        :description => current_user.name
      )
      if customer
        current_user.stripe_customer_id = customer.id
        current_user.save
      end
    end

    customer_id = current_user.stripe_customer_id

    stripe_charge = Stripe::Charge.create(  #create stripe charge to charge customer
      {
        :customer    => customer_id,
        :amount      => amount,
        :description => event.title,
        :currency    => 'usd',
        :application_fee => fee
      },
      event.host.stripe_token               #host token from event host stripe connect
    )

    charge = Charge.new                     #create new record of charge in db
    charge.user_id = current_user.id        #useful for issuing refunds
    charge.event_id = event.id
    charge.stripe_charge = stripe_charge.id
    charge.amount = stripe_charge.amount
    charge.fee_collected = fee
    
    if charge.save
      render json: charge, status: :created #if succesful, send back 200
    else
      render status: :internal_server_error #else send back 500
    end

  rescue Stripe::CardError => e
    flash[:error] = e.message               # pass key in view: `error`
    render json: e
    return
  rescue => e
    render json: e
    return
  end

end
