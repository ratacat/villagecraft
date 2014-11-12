Rails.configuration.stripe = {
  :publishable_key => 'pk_live_4aOC2jj4S9mYQnFVfhUIPJc1',
  :secret_key      => 'sk_live_4aOClJEMsLtrqAySFo8eGiNO'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

CLIENT_ID = "ca_4g1PNBMeAuMp71H91YNaoeJbgnh4ekBp"