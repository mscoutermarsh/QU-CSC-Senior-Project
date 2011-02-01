require 'dm-serializer/to_json'
require 'dm-serializer/to_xml'

# contains all owner (users) specific data

class Owner

  include DataMapper::Resource

  property :id, Serial
  property :username, String, :required => true
  property :email, String, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :name, :owner, :color

  validates_format_of :email,
                      :with => /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i

end
