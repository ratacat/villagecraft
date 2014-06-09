class EventOrganization < ActiveRecord::Base
  attr_accessible :event_id, :organization_id
  belongs_to :event
  belongs_to :organization
end
