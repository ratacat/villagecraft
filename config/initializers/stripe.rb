Rails.configuration.stripe = {
  :publishable_key => ENV['PUBLISHABLE_KEY'],
  :secret_key      => ENV['SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

CLIENT_ID = Rails.env.production? ? ENV["CLIENT_ID"] : "ca_4g1PNBMeAuMp71H91YNaoeJbgnh4ekBp"