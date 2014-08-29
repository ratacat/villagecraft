class ChargesController < ApplicationController

# POST /charges
  def create
    event = Event.find(params[:event_id])
    token = params[:stripeToken]
    amount = (event.price.to_i) * 100
    
    unless (fee = amount / 10) > 100
      fee = 100
    end

    Stripe::Charge.create(
      {
        :card        => token,
        :amount      => amount,
        :description => event.title,
        :currency    => 'usd',
        :application_fee => fee
      },
      event.host.stripe_token # token from event host stripe connect
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message # pass key in view: `error`
    render json: e
    return
  end

end
