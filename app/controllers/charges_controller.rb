class ChargesController < ApplicationController

# POST /charges
  def create
    event = Event.find(params[:event_id])
    token = params[:stripeToken]
    amount = (event.price.to_i) * 100
    
    unless (fee = amount / 17) > 200        #set application fee to 17% or $2 whichever is greater
      fee = 200
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
        :description => event.title,        #there are a few mods to make this run in development  
        :currency    => 'usd',              #removed a comma
       :application_fee => fee              #commented out
      }                                     #removed a comma
     event.host.stripe_token                #commented out #host token from event host stripe connect
    )

    charge = Charge.new                     #create new record of charge in db
    charge.user_id = current_user.id        #useful for issuing refunds
    charge.event_id = event.id
    charge.stripe_charge = stripe_charge.id
    charge.amount = stripe_charge.amount
    charge.fee_collected = fee
    
    if charge.save
      render json: charge, status: :created #if succesful, send back 200
    else                                    #TODO: if stripe success, but server error
      render json: "Stripe charge succeeded, but no db record was made"
    end

  rescue => e
    puts
    puts "*******"
    puts "ERROR: " + e.message
    puts "*******"
    render json: e.message
  end

end
