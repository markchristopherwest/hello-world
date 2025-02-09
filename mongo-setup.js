db.createCollection("first"); db.createCollection("second"); db.createCollection("third");


print("Started Adding the Users.");

db = db.getSiblingDB("admin");
db.createUser({
  user: "dude",
  pwd: "changeme",

  roles: [ { role: "readWrite", db: "hello_world" },
    { role: "readWrite", db: "admin" } ],
    mechanisms: ["SCRAM-SHA-1", "SCRAM-SHA-256"]
});
print("End Adding the User Roles.");


db.createUser({
  user: "dude",
  pwd: "changeme",

  roles: [ { role: "readWrite", db: "hello_world" },
    { role: "readWrite", db: "admin" } ],
    mechanisms: ["SCRAM-SHA-1", "SCRAM-SHA-256"]
});

db.auth( {
  user: "dude",
  pwd: "changeme",
  mechanism: "SCRAM-SHA-256"
} )

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

