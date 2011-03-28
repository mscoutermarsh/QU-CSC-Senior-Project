

# contains all pet specific data

class Pet

  include DataMapper::Resource

  property :name, String, :required => true
  property :level, Integer, :required => true
  property :hunger, Integer, :default => 75
  property :mood, Integer, :default => 75
  property :alive, Boolean, :default => true
  property :api_key, String, :required => true, :unique => true, :key => true,
    :messages => {
      :presence  => 'API Key required.',
      :is_unique => 'Error: duplicate key'
    }
  property :cleanliness, Integer, :default =>100
  property :created_at, DateTime
  property :updated_at, DateTime
  property :lastFed, DateTime
  property :lastCleaned, DateTime
  property :lastPlayedWith, DateTime
  property :email, String, :required => true,
    :format   => :email_address,
    :messages => {
      :presence  => 'Email required.',
      :is_unique => 'We already have that email.',
      :format    => 'Does not look like an email address to me ...'
    }

  validates_presence_of :name, :api_key, :level, :email
  validates_numericality_of :mood, :only_integer => true, :greater_than_or_equal_to => 0,
                            :less_that_or_equal_to => 100
  validates_numericality_of :hunger, :only_integer => true, :greater_than_or_equal_to => 0,
                            :less_that_or_equal_to => 100
  validates_numericality_of :cleanliness, :only_integer => true, :greater_than_or_equal_to => 0,
                            :less_that_or_equal_to => 100



end
