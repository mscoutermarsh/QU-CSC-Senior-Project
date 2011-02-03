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

POST
----

### Create a new pet
`Post: http://localhost:4567/pets`

**Params required:** name (string) and color (string).

By default the pet will have a mood of 100, hunger of 75, cleanliness of 75.

For mood, hunger and cleanliness - 100 is good. 0 is bad.

GET
---

#### Get pet data
Get: http://localhost:4567/pets

-Returns ALL pet data for every pet in json.

#### All data for specific pet
`Get: http://localhost:4567/pets/id`
-Returns pet data for id (integer).

#### Hunger
`Get: http://localhost:4567/pets/id/hunger`

-Returns hunger of pet(id).

#### Mood
`Get: http://localhost:4567/pets/id/mood`

-Returns mood of pet(id).

#### Cleanliness
`Get: http://localhost:4567/pets/id/cleanliness`

-Returns cleanliness of pet(id).

#### Age
`Get: http://localhost:4567/pets/id/age`

-Returns age of pet(id) in minutes.

PUT
---

### Clean
`Put: http://localhost:4567/pets/id/clean`

### Feed
`Put: http://localhost:4567/pets/id/feed`

### Play
`Put: http://localhost:4567/pets/id/play`

