class ChargesController < ApplicationController

# POST /charges
  def create
    event = Event.find(params[:event_id])
    token = params[:stripeToken]
    amount = (event.price.to_i) * 100

    charge = Stripe::Charge.create(
      {
        :card        => token,
        :amount      => amount,
        :description => event.title,
        :currency    => 'usd'
      }
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message # pass key in view: `error`
    render json: e
    return
  end

end
