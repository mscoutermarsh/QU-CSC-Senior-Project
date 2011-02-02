2010-2011 QU Senior Project
===========================
mscoutermarsh

Virtual Pet API

Documentation
-------------

Each pet contains the following attributes:
+ name (string)
+ owner (integer)
+ color (string)
+ mood (integer)
+ hunger (integer)
+ cleanliness (integer)
+ created_at (datetime)
+ updated_at (datetime)

### Create a new pet
**Post to:** http://localhost:4567/pets
**Params required:** name (string) and color (string)
By default the pet will have a mood of 100, hunger of 75, cleanliness of 75.

For mood, hunger and cleanliness - 100 is good. 0 is bad.

-------------
#### Get pet data
**Get to:** http://localhost:4567/pets

Returns ALL pet data for every pet in json.

#### All data for specific pet
**Get to:** http://localhost:4567/pets/id

Returns pet data for id (integer).

#### Hunger
**Get to:** http://localhost:4567/pets/id/hunger

Returns hunger of pet(id).

#### Mood
**Get to:** http://localhost:4567/pets/id/mood

Returns mood of pet(id).

#### Cleanliness
**Get to:** http://localhost:4567/pets/id/cleanliness

Returns cleanliness of pet(id).

#### Age
**Get to:** http://localhost:4567/pets/id/age

Returns age of pet(id) in minutes.
