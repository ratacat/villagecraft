module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module LinkTop
      # Name of the component method
      def link_top
        @link_top ||= begin
          options[:link_top].to_s.html_safe if options[:link_top].present?
        end
      end

      # Used when the number is optional
      def has_link_top?
        link_top.present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::LinkTop)