module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module LinkBottom
      # Name of the component method
      def link_bottom
        @link_bottom ||= begin
          options[:link_bottom].to_s.html_safe if options[:link_bottom].present?
        end
      end

      # Used when the number is optional
      def has_link_bottom?
        bottom_top.present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::LinkBottom)