class Notification < ActiveRecord::Base
  attr_accessible :user, :activity, :email_me, :emailed_at
  has_uuid(:length => 8)
  acts_as_paranoid

  belongs_to :user
  alias :target :user

  belongs_to :activity, :class_name => 'PublicActivity::Activity'
  has_one :event, :through => :activity, :source => :trackable, :source_type => "Event"

  validates :user_id, presence: true
  validates :activity_id, presence: true

  # DON'T USE / FIXME: daemon chokes here: undefined  `inline_venue'
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
    action_view.render inline: "<%= strip_tags(render_activity notification.activity, :profile_image_size => :none, :show_trackable => true, :plaintext => true, :show_ago => false).strip.html_safe %>", locals: {:notification => self}
  end

end
