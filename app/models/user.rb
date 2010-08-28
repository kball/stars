class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :email, String
  property :facebook_uid, Integer, :min => 1, :max => 2**64 - 1
  property :facebook_session_key, String
  property :persistence_token, String
  property :created_at, Time
  property :updated_at, Time
  property :active, Boolean, :default => true

  has n, :stars, :child_key => :to_id

  def self.active
    all(:active => true)
  end

  Superstar = Struct.new(:user, :count, :seconds, :stars)
  def self.superstars_for(week, limit=3)
    monday = week.beginning_of_week
    stars = Star.during(monday..(monday + 1.week))
    stars.group_by(&:to).map do |user, stars|
      Superstar.new(user, stars.size, stars.map(&:num_seconds).sum, stars)
    end.sort_by do |superstar|
      # Sort by stars+seconds, ties go to the one with more stars
      [superstar.count + superstar.seconds, superstar.count]
    end.reverse.first(limit)
  end

  def can_second?(star)
    return false if [star.from, star.to].include?(self)
    return false if seconded?(star)
    return true
  end

  def most_recent_star
    stars.recent.first
  end

  def others
    User.active.all(:id.not => self.id)
  end

  def second(star)
    Second.create(:star => star, :user => self) if can_second?(star)
  end

  def seconded?(star)
    star.seconded_by?(self)
  end
end
