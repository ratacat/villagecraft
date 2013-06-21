module EventsHelper
  def event_price(event)
    if event.price.blank?
      'Free!'
    else
      number_to_currency(event.price)      
    end
  end
end
