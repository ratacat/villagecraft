class DateSelectInput < SimpleForm::Inputs::Base
  def input
    input_html_options = options[:input_html] || {}
    input_html_options['data-format'] = "yyyy-MM-dd"
    %{
      <div class="input-group date-select-component">
        #{@builder.text_field(attribute_name, input_html_options)}
        <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
      </div>
    }.html_safe
  end
end
