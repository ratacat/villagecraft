class Ability
  include CanCan::Ability

  def initialize(user, session)
    alias_action :edit, :update, :destroy, :accept_attendee, :cancel_attend, :manage_attendees, :to => :manage_as_host

    # anyone
    can [:show, :attend_by_email], Event
    
    # signed-in user  
    if not user.blank?
      can [:show, :attend, :attend_by_email], Event
      cannot :manage_as_host, Event
      
      can [:show], User
      can [:edit, :update, :edit_preferences, :update_preferences], User, :id => user.id
      
      # host
      if user.host?
        can :manage, Workshop, :host_id => user.id
        cannot :index, Workshop
        can :my_workshops, Workshop
        
        can [:new], Event
        can :manage_as_host, Event, :host_id => user.id
        cannot :cancel_attend, Event do |event|
          event.occurred?
        end
        
        can :update, Meeting
      end
      
      # admin
      if user.admin? and session[:admin_mode]
        can :manage, :all
        cannot :manage_attendees, Event, :external => true
      end
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end