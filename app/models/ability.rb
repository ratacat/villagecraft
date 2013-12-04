class Ability
  include CanCan::Ability

  def initialize(user, session)
    alias_action :update, :destroy, :accept_attendee, :cancel_attend, :to => :manage_as_host
    
    if user.blank? # guest user
      can [:show, :attend_by_email], Event
    elsif user.admin? and session[:admin_mode] # admin
      can :manage, :all
    elsif user.host? # host
      can [:show, :new, :attend, :attend_by_email], Event
      can :manage_as_host, Event, :host_id => user.id
      can :update, Meeting      
    else # signed in user
      can [:show, :attend, :attend_by_email], Event
      cannot :manage_as_host
      can :update, Meeting
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