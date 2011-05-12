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
#require 'logger'

#Dir.mkdir('logs') unless File.exist?('logs')
#$log = Logger.new('logs/output.log','weekly')
#$log.debug "hello"
#
#configure :production do
#  $log.level = Logger::WARN
#end
#configure :development do
#  $log.level = Logger::DEBUG
#end

#### pet API

# Import all Models
require File.dirname(__FILE__) + '/models/pet.rb'

# Set up database
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/pets.db")

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
    "#{base_url}pets/#{pet.id}"
  end

  def rfc_3339(timestamp)
    timestamp.strftime("%Y-%m-%dT%H:%M:%SZ")
  end

  # checks time since pet was last interacted with... reduces
  # mood/cleanliness/hunger
  def updateData(pet)
    today = DateTime.now

    ### UPDATE MOOD

    # find last time pet was played with
    minsSince = ((today - pet.lastPlayedWith) * 24 *60).to_i

    # Mood is 50% cleanliness and hunger
    # And 50% based on the last time the pet was played with

    hungerCleanMood = (pet.cleanliness/4)+(pet.hunger/4)

    moodReduce = ((minsSince / 30) * (pet.level * 2)) # subtract level for every 30 mins

    if moodReduce > 100 then
      pet.mood = 0
    else
      pet.mood = hungerCleanMood + (50 - moodReduce)
    end


    ### UPDATE HUNGER

    # find last time pet was fed
    minsSince = ((today - pet.lastFed) * 24 *60).to_i

    hungerReduce = ((minsSince / 20) * (pet.level*2)) # subtract level for every 20 mins

    pet.hunger = pet.hunger - hungerReduce

    if pet.hunger < 0 then
      pet.hunger = 0
    end

    ### UPDATE CLEANLINESS

    # find last time pet was cleaned
    minsSince = ((today - pet.lastCleaned) * 24 *60).to_i

    cleanReduce = ((minsSince / 25) * (pet.level * 2)) # subtract level for every 25 mins

    pet.cleanliness = pet.cleanliness - cleanReduce

    if pet.cleanliness < 0 then
      pet.cleanliness = 0
    end

    if pet.cleanliness == 0 and pet.hunger == 0 and pet.mood == 0 then
      # pet is dead :-(
      pet.alive = false
    end

    # since we just reduced attributes... update time stamps so that
    # they are not reduced again if updateData is called.
    pet.lastFed = DateTime.now()
    pet.lastCleaned = DateTime.now()

    pet.save

  end

end



# POST
# Create pet
#

# name and level required to create pet
post '/pet/?' do
  #gen new API key
  api_key = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..12]

  pet = Pet.new(:name => params[:name],:level=> params[:level],:email=>params[:email], :api_key => api_key, :lastFed => DateTime.now(), :lastCleaned => DateTime.now(), :lastPlayedWith => DateTime.now()  )

  if pet.save
    status(201)

    pet.api_key
  else
    status(412)
  end
end

# feed the pet
post '/pet/:key/feed/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    if pet.alive == false then
      status(410)
      "Pet is dead"
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

      # eating makes pet dirtier
      pet.cleanliness = pet.cleanliness - 10

      pet.lastFed = DateTime.now()

      pet.save

      status(202)
    end
  end
end

# clean the pet
post '/pet/:key/clean/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    if pet.alive == false then
      status(410)
      "Pet is dead"
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

      pet.lastCleaned = DateTime.now()

      pet.save

      status(202)
    end
  end
end

# play with the pet
post '/pet/:key/play/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    if pet.alive == false then
      status(410)
      "Pet is dead"
    else
      # playing with pet increases mood
      # Also - makes pet dirtier and more hungry.
      pet.cleanliness = pet.cleanliness - 5
      pet.hunger = pet.hunger - 5

      pet.lastPlayedWith = DateTime.now()

      pet.save

      status(202)
    end
  end
end

# Rejuvenate - if pet is dead. Revive and set attributes to 100.
post '/pet/:key/rejuvenate/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    pet.cleanliness = 100
    pet.hunger = 100
    pet.alive = true

    pet.lastPlayedWith = DateTime.now()
    pet.lastFed = DateTime.now()
    pet.lastCleaned = DateTime.now()

    pet.save

    status(202)
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

# return all of pet attributes data
get '/pet/:key/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil then
    status(404)

  else
    updateData(pet)
    content_type :json
    today = DateTime.now
    theAge = (today - pet.created_at)
    theAge = ((theAge * 24 * 60).to_i)
    essentialInfo = {mood=> pet.mood, alive=> pet.alive, hunger=> pet.hunger, cleanliness=> pet.cleanliness, age=>theAge}
    essentialInfo.to_json
  end
end

# return pets hunger
get '/pet/:key/hunger/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil then
    status(404)

  else
    updateData(pet)
    content_type :json
    pet.hunger.to_json
  end
end

# return pets cleanliness
get '/pet/:key/cleanliness/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil then
    status(404)

  else
    updateData(pet)
    content_type :json
    pet.cleanliness.to_json
  end
end

# return pets age
get '/pet/:key/age/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil then
    status(404)

  else
    today = DateTime.now
    age = (today - pet.created_at)
    content_type :json
    ((age * 24 * 60).to_i).to_json
  end
end

# return pets mood
get '/pet/:key/mood/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil then
    status(404)

  else
    updateData(pet)
    content_type :json
    pet.mood.to_json
  end
end

# return if pet is alive
get '/pet/:key/alive/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil then
    status(404)

  else
    updateData(pet)
    content_type :json
    pet.alive.to_json
  end
end

# return pets level
get '/pet/:key/level/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil then
    status(404)

  else
    content_type :json
    pet.level.to_json
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
