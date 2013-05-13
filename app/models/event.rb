class Event < ActiveRecord::Base
  attr_accessible :description, :title, :date, :time

  belongs_to :user
  validates :user_id, presence: true

  def date
    datetime && datetime.strftime("%Y-%m-%d")
  end

  def time
    datetime && datetime.strftime("%I:%M %p")
  end

  def date=(date)
    self.datetime = Time.zone.parse(date, datetime || Time.now)
  end

  def time=(time)
    self.datetime = Time.zone.parse(time, datetime || Time.now)
  end

end
