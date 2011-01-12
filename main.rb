require 'rubygems'
require 'sinatra'
require 'activerecord'

configure do

  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'pets.sqlite3')

  begin
    ActiveRecord::Schema.define do
      create_table :pets do |t|
        t.text :name, :null => false
        t.text :color, :null => false

        # mood and hunger default to 75
        t.integer :hunger, :default => 75
        t.integer :mood, :default => 75

        t.timestamps
        t.text :owner, :null => false
      end
    end
  rescue ActiveRecord::StatementInvalid
    # Do nothing, since the schema already exists
  end

  CREDENTIALS = ['mike', 'c']

end

class Pet < ActiveRecord::Base

attr_accessible :name, :owner, :mood, :color, :hunger
#  validates_presence_of :name, :owner, :color
#  validates_numericality_of :mood, :only_integer => true, :greater_than_or_equal_to => 0,
#                            :less_that_or_equal_to => 100
#  validates_numericality_of :hunger, :only_integer => true, :greater_than_or_equal_to => 0,
#                            :less_that_or_equal_to => 100


  named_scope :recent, {:limit => 10, :order => 'updated_at DESC'}
end

helpers do

  def base_url
    if Sinatra::Application.port == 80
      "http://#{Sinatra::Application.host}/"
    else
      "http://#{Sinatra::Application.host}:#{Sinatra::Application.port}/"
    end
  end

  def pet_url(pet)
    "#{base_url}pets/#{pet.id}"
  end

  def rfc_3339(timestamp)
    timestamp.strftime("%Y-%m-%dT%H:%M:%SZ")
  end

  def protected!
    auth = Rack::Auth::Basic::Request.new(request.env)

    # Request a username/password if the user does not send one
    unless auth.provided?
      response['WWW-Authenticate'] = %Q{Basic Realm="Shortener"}
      throw :halt, [401, 'Authorization Required']
    end

    # A request with non-basic auth is a bad request
    unless auth.basic?
      throw :halt, [400, 'Bad Request']
    end

    # Authentication is well-formed, check the credentials
    if auth.provided? && CREDENTIALS == auth.credentials
      return true
    else
      throw :halt, [403, 'Forbidden']
    end
  end

end

post '/pets' do
  pet = Pet.new(:name => params[:name], :color => params[:color], :owner => 1)
  #pet.name = params[:name]
  #pet.color = params[:color]
  #pet.owner = 1
  if pet.save
    status(201)
    response['Location'] = Pet_url(pet)

    "Created new pet #{pet.id} with color \"#{pet.color}\"\n"
  else
    status(412)

    "Fail.\n"
  end
end

get '/pets/:id.:format' do
  Pet = Pet.find(params[:id])
  case params[:format]
  when 'xml'
    content_type :xml
    Pet.to_xml
  when 'json'
    content_type('application/json')
    Pet.to_json
  else
    content_type :json
    Pet.to_json
  end
end

put '/pets/:id' do
  pet = Pet.find(params[:id])
  pet.body = params[:body]
  if pet.save
    status(202)
    'pet updated'
  else
    status(412)
    "Error updating pet.\n"
  end
end

delete '/pets/:id' do
  Pet.destroy(params[:id])
  status(200)
  "Deleted\n"
end

get '/pets' do
  pets = Pet.recent.all
  content_type 'application/json'
  pets.to_json
end

delete '/pets' do
  protected!
  Pet.delete_all
  status(204)
end

error ActiveRecord::RecordNotFound do
  status(404)
  @msg = "record not found\n"
end

not_found do
  status(404)
  @msg || "404\n"
end