require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-serializer/to_json'
require 'dm-serializer/to_xml'
require 'dm-validations'

#### pet API

# Import all Models
Dir.glob("#{Dir.pwd}/models/*.rb") { |m| require "#{m.chomp}" }

#Set up database
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/pets.sqlite3")

# Initialize (finalize) db
DataMapper.finalize

# Create the db/tables if they don't exist
DataMapper::auto_upgrade!

helpers do

  def base_url
    if Sinatra::Application.port == 80
      "http://#{Sinatra::Application.host}/"
    else
      "http://#{Sinatra::Application.host}:#{Sinatra::Application.port}/"
    end
  end

  def pet_url(pet)
    "#{base_url}pets/#{pet.id}.xml"
  end

  def rfc_3339(timestamp)
    timestamp.strftime("%Y-%m-%dT%H:%M:%SZ")
  end

#  def protected!
#    auth = Rack::Auth::Basic::Request.new(request.env)
#
#    # Request a username/password if the user does not send one
#    unless auth.provided?
#      response['WWW-Authenticate'] = %Q{Basic Realm="Shortener"}
#      throw :halt, [401, 'Authorization Required']
#    end
#
#    # A request with non-basic auth is a bad request
#    unless auth.basic?
#      throw :halt, [400, 'Bad Request']
#    end
#
#    # Authentication is well-formed, check the credentials
#    if auth.provided? && CREDENTIALS == auth.credentials
#      return true
#    else
#      throw :halt, [403, 'Forbidden']
#    end
#  end

end

# POST
# Create pet
#

post '/pets' do
  pet = Pet.new(:name => params[:name], :color => params[:color], :owner => 1)
  if pet.save
    status(201)
    #response['Location'] = Pet_url(pet)

    "Created new pet #{pet.name}(#{pet.id}) with color \"#{pet.color}\"\n"
  else
    status(412)
    
    error = "Missing "

    if params[:name] == nil and params[:color] == nil then
      error = error + "name and color parameters."
    elsif params[:name] == nil then
      error = error + "name parameter."
    else
      error = error + "color parameter."
    end if

    error
  end
end

# PUT
# Feed pet
#

put '/pets/:id/feed/?' do
  pet = Pet.find(params[:id])
  if pet.hunger < 100 then
    if pet.hunger < 50 then
      pet.hunger = pet.hunger + 50
    else if pet.hunger < 75 then
        pet.hunger = pet.hunger + 25
    else
      pet.hunger = 100
    end
    if pet.save
      status(202)
    else
      status(412)
      "Pet could not be found.\n"
    end
  end
  end
end

# GET
# pet data in json or XML
#

get '/pets/?' do
  @pets = Pet.all()
  content_type :json
  @pets.to_json
end

get '/pets/:id.:format?/?' do
  pet = Pet.find(params[:id])
  case params[:format]
  when 'xml'
    content_type :xml
    pet.to_xml
  when 'json'
    content_type :json
    pet.to_json
  else
    content_type :json
    pet.to_json
  end
end

delete '/pets/:id/?' do
  Pet.destroy(params[:id])
  status(200)
  "Deleted\n"
end

not_found do
  status(404)
  @msg || "404 sorry\n"
end