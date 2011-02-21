require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-serializer/to_json'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-validations'
require 'date'
require 'digest/sha1'
require 'dm-postgres-adapter'

#### pet API

# Import all Models
Dir.glob("#{Dir.pwd}/models/*.rb") { |m| require "#{m.chomp}" }

# Set up database
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/pets.db")

# Initialize (finalize) db
DataMapper.finalize

# Create the db/tables if they don't exist
DataMapper::auto_upgrade!

#DataMapper.auto_migrate!

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

end



# POST
# Create pet
#

# name and color required to create pet
post '/pet/?' do
  #gen new API key
  api_key = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..12]

  pet = Pet.new(:name => params[:name],:color=> params[:color],:email=>params[:email], :api_key => api_key)

  if pet.save
    status(201)

    "Created new pet #{pet.name}(#{pet.id}) KEY: #{pet.api_key}\n"
  else
    status(412)
  end
end

# PUT
# update pet data
#

# feed the pet
put '/pet/:key/feed/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else

    if pet.hunger < 100 then
      if pet.hunger < 50 then
        pet.hunger = pet.hunger + 50
      else if pet.hunger < 75 then
          pet.hunger = pet.hunger + 25
        else
          pet.hunger = 100
        end
      end
    end
    pet.save
    status(202)
    "Pet #{pet.name}(#{pet.id}) fed. now has a hunger of \"#{pet.hunger}\"\n"
  end
end

# clean the pet
put '/pet/:key/clean/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else

    if pet.cleanliness < 100 then
      if pet.cleanliness < 50 then
        pet.cleanliness = pet.cleanliness + 50
      else if pet.cleanliness < 75 then
          pet.cleanliness = pet.cleanliness + 25
        else
          pet.cleanliness = 100
        end
      end
    end
    pet.save
    status(202)
    "Pet #{pet.name}(#{pet.id}) cleaned. now has a cleanliness of \"#{pet.cleanliness}\"\n"
  end
end

# play with the pet
put '/pet/:key/play/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    if pet.mood < 100 then
      if pet.cleanliness < 50 then
        pet.cleanliness = pet.cleanliness + 50
      else if pet.cleanliness < 75 then
          pet.cleanliness = pet.cleanliness + 25
        else
          pet.cleanliness = 100
        end
      end
    end
    pet.save
    status(202)
    "Pet #{pet.name}(#{pet.id}) cleaned. now has a cleanliness of \"#{pet.cleanliness}\"\n"
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
get '/pet/:key/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    content_type :json
    pet.to_json
  end
end

# return pets hunger
get '/pets/:key/hunger/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    content_type :json
    pet.hunger.to_json
  end
end

# return pets cleanliness
get '/pet/:key/cleanliness/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    content_type :json
    pet.hunger.to_json
  end
end

# return pets mood
get '/pet/:key/mood/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    content_type :json
    pet.mood.to_json
  end
end

# return pets age
get '/pet/:key/age/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    today = DateTime.now
    age = (today - pet.created_at)
    content_type :json
    ((age * 24 * 60).to_i).to_json
  end
end

delete '/pet/:key/?' do
  Pet.destroy(params[:id])
  status(200)
  "Deleted\n"
end

not_found do
  status(404)
  @msg || "404 sorry\n"
end