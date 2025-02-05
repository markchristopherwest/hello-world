db.createCollection("first"); db.createCollection("second"); db.createCollection("third");


print("Started Adding the Users.");
db = db.getSiblingDB("admin");
db.createUser({
  user: "dude",
  pwd: "changeme",

  roles: [ { role: "readWrite", db: "hello-world" },
    { role: "readWrite", db: "admin" } ]
});
print("End Adding the User Roles.");

use('hello-world');

db.posts.insertMany([  
    {
      title: "Post Title 2",
      body: "Body of post.",
      category: "Event",
      likes: 2,
      tags: ["news", "events"],
      date: Date()
    },
    {
      title: "Post Title 3",
      body: "Body of post.",
      category: "Technology",
      likes: 3,
      tags: ["news", "events"],
      date: Date()
    },
    {
      title: "Post Title 4",
      body: "Body of post.",
      category: "Event",
      likes: 4,
      tags: ["news", "events"],
      date: Date()
    }
  ]);


  db.createUser(
    {
      user: "dude",
      pwd:  "dude",   // or cleartext password
      roles: [ { role: "readWrite", db: "hello-world" },
               { role: "read", db: "reporting" } ]
    }
  );

  db.runCommand({updateUser: "dude", pwd: "dude", mechanisms: ["SCRAM-SHA-1"]});
