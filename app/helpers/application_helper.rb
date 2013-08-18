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
  
  def icon_meter(options={})
    defaults = {
      :rows => 2, 
      :columns => 10,
      :icon => 'icon-user',
      :min => 0,
      :max => 20,
      :value => 0,
      :table_class => 'table meter tooltipify',
      :tooltip_placement => 'left'
    }
    options.reverse_merge!(defaults)
    content_tag(:table, 
                :class => options[:table_class], 
                :style => "width: #{options[:columns]}em;", 
                :title => options[:title], 
                :'data-placement' => options[:tooltip_placement]) do
      content_tag(:tbody) do
        html = ''
        options[:rows].times do |r|
          html += '<tr>'
          options[:columns].times do |c|
            html += '<td>'
            i = options[:rows]*c + r
            unless i >= options[:max]
              icon_class = [options[:icon]]
              if options[:value] > i
                icon_class << 'text-success'
              elsif options[:min] > i
                icon_class << 'text-error'
              else
                icon_class << 'muted'
              end
              html += content_tag(:i, '', :class => icon_class.join(' '))
            end
            html += '</td>'
          end
          html += '</tr>'
        end
        html.html_safe
      end
    end
  end
  
end
