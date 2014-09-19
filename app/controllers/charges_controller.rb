class ChargesController < ApplicationController

# POST /charges
  def create
    event = Event.find(params[:event_id])
    token = params[:stripeToken]
    amount = (event.price.to_i) * 100
    
    unless (fee = amount / 10) > 100
      fee = 100
    end

    unless current_user.stripe_customer_id
      binding.pry
      customer = Stripe::Customer.create(
        :card => token[:id],
        :description => current_user.name
      )
      if customer
        current_user.stripe_customer_id = customer.id
        current_user.save
      end
    end

    customer_id = current_user.stripe_customer_id

    Stripe::Charge.create(
      {
        :customer    => customer_id,
        :amount      => amount,
        :description => event.title,
        :currency    => 'usd',
        :application_fee => fee
      },
      event.host.stripe_token # host token from event host stripe connect
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message # pass key in view: `error`
    render json: e
    return
  rescue => e
    render json: e
    return
  end

end
