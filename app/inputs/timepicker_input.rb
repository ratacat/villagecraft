class TimepickerInput < SimpleForm::Inputs::Base
  def input
    input_html_options = options[:input_html_options] || {}
    %{
      <div class="input-append bootstrap-timepicker">
        #{@builder.text_field(attribute_name, input_html_options)}
        <span class="add-on"><i class="icon-time"></i></span>
      </div>
    }.html_safe
  end
end