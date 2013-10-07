class Notification < ActiveRecord::Base
  attr_accessible :user, :activity
  has_uuid(:length => 8)

  belongs_to :user
  alias :target :user

  belongs_to :activity, :class_name => 'PublicActivity::Activity'
  attr_accessible :seen, :sent

  after_create :send_sms

  def to_s
    action_view = ActionView::Base.new(Rails.configuration.paths["app/views"])
    action_view.class_eval <<-EVAL 
      include Rails.application.routes.url_helpers
      include ApplicationHelper
      include ActivitiesHelper
      include EventsHelper
      include UsersHelper

      def protect_against_forgery?
        false
      end
      
      def current_user
        User.find_by_uuid('#{self.user.uuid}')
      end
    EVAL
    action_view.render inline: "<%= strip_tags(render_activity notification.activity, :profile_image_size => :none, :show_trackable => true, :plaintext => true, :show_ago => false).strip %>", locals: {:notification => self}
  end

  protected
  def send_sms
    self.user.send_sms(self.to_s)
  end

end
