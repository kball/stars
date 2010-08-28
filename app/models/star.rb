require 'second'
class Star
  include DataMapper::Resource
  property :id, Serial
  property :reason, String
  property :created_at, Time
  property :updated_at, Time

  #default_scope :include => :seconds

  belongs_to :from, 'User'
  belongs_to :to,   'User'

  has n, :seconds

  def self.during(range)
    start = range.first.to_time.utc
    finish = range.last.to_time.utc
    all(:created_at.gt => start, :created_at.lt => finish)
  end

  def self.recent(count = nil)
    count ||= 10
    all(:order => :id.desc, :limit => count)
  end

  def self.past_week_by_user
    Star.all(:created_at.gt => 1.week.ago).
         group_by(&:to).
         sort_by {|(user, stars)| stars.size}.reverse
  end

  def num_seconds
    seconds.count
  end

  def seconded_by?(user)
    !!seconds.detect{|s| s.user == user}
  end

  def value
    1 + num_seconds
  end

  #after_create do |star|
  #  Mailer.deliver_star(star)
  #end
end
