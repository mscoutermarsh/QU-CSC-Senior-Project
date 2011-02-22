

# log of all actions performed on pet

class Log

  include DataMapper::Resource

  property :action, String, :required => true
  property :api_key, String, :required => true, :key => true
  property :created_at, DateTime

  validates_presence_of :action, :api_key



end
