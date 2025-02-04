#!/bin/bash

# Log Everything
sudo touch /var/log/user-data.log
sudo chown root:adm /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'


# Update Everything
sudo apt-get update

# Tools
sudo apt-get install -y awscli s3fs 



# Install Services to Target
echo "Installing MongoDB"
sudo apt-get install gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

sudo mkdir -p /data/db
sudo chown -R $USER /data/db 
sudo chmod -R go+w /data/db

sudo systemctl daemon-reload

sudo systemctl start mongod

sudo systemctl status mongod

sudo systemctl enable mongod

mongo redirect --eval 'db.createCollection("first"); db.createCollection("second"); db.createCollection("third")'
mongo redirect --eval "db.addUser(${mongo_username}, ${mongo_password})"

# Install OMZ
# sudo apt-get install -y zsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# sudo omz update

echo END
