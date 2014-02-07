module UsersHelper
  def user_thumb(user, options={})
    defaults = {
      :size => :thumb,
      :only_path => true,
      :linked => false,
      :title => nil
    }
    options.reverse_merge!(defaults)
    html = image_tag(user.try(:profile_img_src, options[:size]) || User.homunculus_src(options[:size]), :class => "user_thumb img-rounded #{options[:size]}")
    (options[:linked] and not user.blank?) ? link_to(html, user_url(user, :only_path => options[:only_path], :title => options[:title], :class => 'user_thumb')) : html
  end
  
  def linked_user_thumb(user, options={})
    options[:linked] = true
    user_thumb(user, options)
  end
  
  def contextualized_user_link(user, options={})
    defaults = {
      :linked => true,
      :only_path => true,
      :annotate => false
    }
    options.reverse_merge!(defaults)
    linked = 
      if options[:linked] == true
        true
      elsif (options[:linked] == :to_hosts_only) and (user.host?)
        true
      else
        false
      end
    if user.nil?
      'a deleted user'
    elsif linked
      link_to contextualized_user_name(user, options), user_url(user, :only_path => options[:only_path])
    else
      contextualized_user_name(user, options)
    end
  end
  
  def user_phone(user)
    number_to_phone user.phone[2..-1], area_code: true
  end
  
  def formatted_velocity(user)
    number_to_percentage(user.velocity * 100, precision: 0)
  end
  
  def contextualized_user_name(user, options={})
    defaults = {
      :annotate => false,
      :viewer => defined?(current_user) ? current_user : nil
    }
    options.reverse_merge!(defaults)
    name = 
    if user.blank?
      'a former user'
    elsif user === options[:viewer]
      options[:capitalize] ? 'You' : 'you'
    elsif options[:annotate]
      annotated_user_name(user)
    else
      user.name
    end
    name
  end
  
  def annotated_user_name(user, options={})
    html = ''.html_safe
    html << user.name
    if user.external?
      html << " ".html_safe
      html << content_tag(:sup, content_tag(:i, '', :class => 'icon-external-link'))
    end
    html
  end
  
  def rich_user_thumbnail(user, options={})
    defaults = {
      :thumbnail_classes => 'thumbnail right-caption clearfix',
      :user_link_options => {},
      :linked => true,
      :thumb_size => :thumb
    }
    options.reverse_merge!(defaults)
    options[:user_link_options].reverse_merge!({:linked => options[:linked]})
    content_tag(:div, :class => options[:thumbnail_classes]) do
      user_thumb(user, {:size => options[:thumb_size], :linked => options[:linked]}) +
      contextualized_user_link(user, options[:user_link_options])
    end
  end
end
