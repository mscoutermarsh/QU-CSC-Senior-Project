require 'dm-serializer/to_json'
require 'dm-serializer/to_xml'

# contains all pet specific data

class Pet

  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  property :color, String, :required => true
  property :hunger, Integer, :default => 75
  property :mood, Integer, :default => 75
  property :owner, Integer
  property :cleanliness, Integer, :default =>100
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :name, :owner, :color
  validates_numericality_of :mood, :only_integer => true, :greater_than_or_equal_to => 0,
                            :less_that_or_equal_to => 100
  validates_numericality_of :hunger, :only_integer => true, :greater_than_or_equal_to => 0,
                            :less_that_or_equal_to => 100
  validates_numericality_of :cleanliness, :only_integer => true, :greater_than_or_equal_to => 0,
                            :less_that_or_equal_to => 100


end
