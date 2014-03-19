class TimeSelectInput < SimpleForm::Inputs::Base
  def input
    input_html_options = options[:input_html] || {}
    %{
      <div class="input-group time-select-component">
        #{@builder.text_field(attribute_name, input_html_options)}
        <span class="input-group-addon"><i class="fa fa-time"></i></span>
      </div>
    }.html_safe
  end
end
