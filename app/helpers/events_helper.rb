module EventsHelper
  def event_price(event)
    if event.price.blank?
      'Free!'
    else
      number_to_currency(event.price)      
    end
  end
  
  def blur_location?(event)
    not (user_signed_in? and (current_user === event.host or current_user.attending_event?(event)))
  end
end
