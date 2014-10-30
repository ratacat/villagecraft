module MessagesHelper
  def message_recipients(message)
    if message.to_user
      contextualized_user_link(message.to_user)
    elsif message.apropos
      case message.apropos
      when Event
        "Attendees of ".html_safe + workshop_title(message.apropos.workshop, :linked_to => true)
      else
        raise "Cannot render message recipients for apropos type: #{message.apropos.class}"
      end
    elsif message.system_message?
      "All Villagecraft Users"
    else
      raise 'Cannot render message recipients'
    end
  end
end
