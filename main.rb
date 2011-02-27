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

  def addToLog(key,action)
    log = Log.new(:api_key => key, :action => action, :created_at => DateTime.now())
    log.save
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

    moodReduce = ((minsSince / 10) * 2) # subtract 2 for every 10 mins

    if moodReduce > 100 then
      pet.mood = 0
    else
      pet.mood = hungerCleanMood + (50 - moodReduce)
    end

    $log.debug "new mood:" + (pet.mood).to_s
    ### UPDATE HUNGER
    
    # find last time pet was fed
    minsSince = ((today - pet.lastFed) * 24 *60).to_i
    
    hungerReduce = ((minsSince / 10) * 2) # subtract 2 for every 10 mins
    
    pet.hunger = pet.hunger - hungerReduce
    
    ### UPDATE CLEANLINESS

    # find last time pet was cleaned
    minsSince = ((today - pet.lastCleaned) * 24 *60).to_i

    cleanReduce = ((minsSince / 20) * 2) # subtract 2 for every 20 mins

    pet.cleanliness = pet.cleanliness - cleanReduce

    pet.save

  end

end



# POST
# Create pet
#

# name and color required to create pet
post '/pet/?' do
  #gen new API key
  api_key = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..12]

  pet = Pet.new(:name => params[:name],:color=> params[:color],:email=>params[:email], :api_key => api_key, :lastFed => DateTime.now(), :lastCleaned => DateTime.now(), :lastPlayedWith => DateTime.now()  )

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

    # eating makes pet dirtier
    if pet.cleanliness < 5 then
      pet.cleanliness = 0
    else
      pet.cleanliness = pet.cleanliness - 5
    end

    pet.lastFed = DateTime.now()
    
    pet.save

    status(202)
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

    pet.lastCleaned = DateTime.now()

    pet.save

    status(202)
  end
end

# play with the pet
put '/pet/:key/play/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil or params[:email]!= pet.email then
    status(401)

  else
    # playing with pet increases mood by 25
    # Also - makes pet dirtier and more hungry.
    if pet.mood < 75 then
      pet.mood = pet.mood + 25
    else
      pet.mood = 100
    end
    if pet.cleanliness > 15 then
      pet.cleanliness = pet.cleanliness - 15
    else
      pet.cleanliness = 0
    end
    if pet.hunger > 15 then
      pet.hunger = pet.hunger - 15
    else
      pet.hunger = 0
    end

    pet.lastPlayedWith = DateTime.now()

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

# return all of pets data
get '/pet/:key/?' do
  pet = Pet.first(:api_key => params[:key])
  if pet == nil then
    status(404)

  else
    updateData(pet)
    content_type :json
    pet.to_json
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
    pet.hunger.to_json
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

delete '/pet/:key/?' do
  Pet.destroy(params[:id])
  status(200)
  "Deleted\n"
end

not_found do
  status(404)
  @msg || "404 sorry\n"
end
