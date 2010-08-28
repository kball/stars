class Second
  include DataMapper::Resource

  property :id, Serial
  property :created_at, Time
  belongs_to :star
  belongs_to :user
end
