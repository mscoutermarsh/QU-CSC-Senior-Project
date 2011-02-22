2010-2011 QU Senior Project
===========================
mscoutermarsh

Virtual Pet API

Documentation
-------------

Each pet contains the following attributes:

+   name (string)
+   owner (integer)
+   color (string)
+   mood (integer)
+   hunger (integer)
+   cleanliness (integer)
+   created_at (datetime)
+   updated_at (datetime)
+   api_key (string)

POST
----

### Create a new pet
`Post: http://localhost:4567/pet`

**Params required:** name (string), color (string), email

By default the pet will have a mood of 100, hunger of 75, cleanliness of 75.

For mood, hunger and cleanliness - 100 is good. 0 is bad.

If the pet is created successfully an API key will be returned. This key must be used to retrieve and update pet data. This key is specifically tied to the email associated with the pet. Both must be used in conjunction for access to be granted.

GET
---

#### Get pet data
`Get: http://localhost:4567/pets`

-Returns ALL pet data for every pet in json.

#### All data for specific pet
`Get: http://localhost:4567/pet/key`

-Returns pet data belonging to KEY.

#### Hunger
`Get: http://localhost:4567/pets/key/hunger`

-Returns hunger of pet.

#### Mood
`Get: http://localhost:4567/pets/key/mood`

-Returns mood of pet.

#### Cleanliness
`Get: http://localhost:4567/pets/key/cleanliness`

-Returns cleanliness of pet.

#### Age
`Get: http://localhost:4567/pets/key/age`

-Returns age of pet in minutes.

PUT
---

For all PUT: Email must be used in conjuction with API_KEY in order to make changes to the pet.

If you recieve a 401 - Unauthorized error. Then either the KEY or email address is incorrect.

### Clean
`Put: http://localhost:4567/pet/key/clean?email=email@address.com`

### Feed
`Put: http://localhost:4567/pet/key/feed?email=email@address.com`

### Play
`Put: http://localhost:4567/pet/key/play?email=email@address.com`

