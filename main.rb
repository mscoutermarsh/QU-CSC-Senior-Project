require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-serializer/to_json'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-validations'
require 'date'

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

end

# POST
# Create pet
#

# name and color required to create pet
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
# update pet data
#

# feed the pet
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
      "Pet #{pet.name}(#{pet.id}) fed. now has a hunger of \"#{pet.hunger}\"\n"
    else
      status(412)
      "Pet could not be found.\n"
    end
  end
  end
end

# clean the pet
put '/pets/:id/clean/?' do
  pet = Pet.find(params[:id])
  if pet.cleanliness < 100 then
    if pet.cleanliness < 50 then
      pet.cleanliness = pet.cleanliness + 50
    else if pet.cleanliness < 75 then
        pet.cleanliness = pet.cleanliness + 25
    else
      pet.cleanliness = 100
    end
    if pet.save
      status(202)
      "Pet #{pet.name}(#{pet.id}) cleaned. now has a cleanliness of \"#{pet.cleanliness}\"\n"
    else
      status(412)
      "Pet could not be found.\n"
    end
  end
  end
end

# GET
# pet data in json
#

# return all pets data
get '/pets/?' do
  @pets = Pet.all()
  content_type :json
  @pets.to_json
end

# return all of pets data
get '/pets/:id/?' do
  pet = Pet.get!(params[:id])
  content_type :json
  pet.to_json
end

# return pets hunger
get '/pets/:id/hunger/?' do
  pet = Pet.get!(params[:id])
  content_type :json
  pet.hunger.to_json
end

# return pets cleanliness
get '/pets/:id/cleanliness/?' do
  pet = Pet.get!(params[:id])
  content_type :json
  pet.hunger.to_json
end

# return pets age
get '/pets/:id/age/?' do
  pet = Pet.get!(params[:id])
  today = DateTime.now
  age = (today - pet.created_at)
  content_type :json
  ((age * 24 * 60).to_i).to_json
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