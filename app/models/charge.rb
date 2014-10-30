class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  attr_accessible :host_id, :stripe_charge
end
