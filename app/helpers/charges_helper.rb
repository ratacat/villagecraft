module ChargesHelper
  def refund(event, attendee=current_user)
    if event.rsvp && event.price > 0
      charge = Charge.where(event_id: event).where(user_id: attendee).limit(1)[0]
      stripe_charge = Stripe::Charge.retrieve(charge.stripe_charge) #grab charge record from stripe

      if refund = stripe_charge.refunds.create #issue stripe refund
        charge.refunded = true #set column in db
        if charge.save
          return true
        else
          raise "refund unsuccessful"
        end
      else
        raise "refund unsuccessful"
      end
      
      return true
    else
      return false
    end

    rescue => e
        puts
        puts "*******"
        puts "ERROR: " + e.message
        puts "*******"
        return false
  end
end
