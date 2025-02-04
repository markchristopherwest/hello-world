#!/bin/bash

# Log Everything
sudo touch /var/log/user-data.log
sudo chown root:adm /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'


sudo useradd -m $mongo_username


sudo apt-get update -y
sudo apt-get install -y awscli s3fs libc6 libcurl4t64 libssl3t64



# Install Services to Target
echo "Installing MongoDB"
sudo apt-get install -y gnupg curl

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt-get update
sudo apt-get install -y mongodb-org


sudo systemctl daemon-reload

sudo systemctl start mongod

sudo systemctl status mongod

sudo systemctl enable mongod

mongosh redirect --eval 'db.createCollection("first"); db.createCollection("second"); db.createCollection("third")'
mongosh redirect --eval "use('hello-world')"
mongosh redirect --eval 'db.posts.insertMany([  
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
])'

mongosh redirect --eval 'db.posts.find()'


# Install OMZ
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo omz update

echo END
