#app/inputs/custom_input.rb
class CustomInput < SimpleForm::Inputs::Base
  def input
    text_field_options = input_html_options.dup
    hidden_field_options = input_html_options.dup
     
    text_field_options[:id] = "datetimepicker1"
    text_field_options[:class] = 'input-append date form-horizontal'
    text_field_options['data-date-format'] = I18n.t('date.datepicker')
 
    hidden_field_options[:id] = "#{attribute_name}_hidden"
 
    return_string =
      "#{@builder.text_field(attribute_name, text_field_options)}\n" +
      "#{@builder.hidden_field(attribute_name, hidden_field_options)}\n"
    return_string = '<div id="datetimepicker1" class="input-append date form-horizontal">
    <input data-format="MM/dd/yyyy" type="text">
    <span class="add-on">
      <i data-time-icon="icon-time" data-date-icon="icon-calendar" class="icon-calendar">
      </i>
    </span>
  </div>'
    return return_string.html_safe
  end
end