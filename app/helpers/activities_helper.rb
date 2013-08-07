module ActivitiesHelper
  def render_activity(activity, options)
    case activity.trackable.class.to_s
    when 'Event'
      event_action(activity, options)
    else
      raise "Don't know how to render activity (#{activity.trackable.class})"
    end
  end
end
