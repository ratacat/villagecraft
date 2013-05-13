class DateSelectInput < SimpleForm::Inputs::Base
  def input
    input_html_options ||= {}
    input_html_options['data-format'] = "yyyy-MM-dd"
    %{
      <div class="input-append date-select-component">
        #{@builder.text_field(attribute_name, input_html_options)}
        <span class="add-on"><i class="icon-calendar"></i></span>
      </div>
    }.html_safe
  end
end
