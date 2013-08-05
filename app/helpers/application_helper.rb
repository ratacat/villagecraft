module ApplicationHelper
  def conjugate(verb, options={})
    plurals = {}
    if options[:second_person]
      verb
    else
      plurals[verb.to_sym] ? plurals[verb.to_sym] : (verb + 's')
    end
  end
end
