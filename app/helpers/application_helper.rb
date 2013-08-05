module ApplicationHelper
  def conjugate(verb, options={})
    plurals = {}
    if options[:second_person]
      verb
    else
      plurals[verb.to_sym] ? plurals[verb.to_sym] : (verb + 's')
    end
  end
  
  def time_ago(time)
    content_tag(:span, distance_of_time_in_words(time, Time.now) + ' ago', :'data-livestamp' => time, :class => 'muted')
  end
end
