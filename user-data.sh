#!/bin/bash

# Log Everything
sudo touch /var/log/user-data.log
sudo chown root:adm /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'


echo "this iteration is ${iteration}"


sudo apt-get update -y
sudo apt-get install -y awscli s3fs



# Install Services to Target
echo "Installing MongoDB"
sudo apt-get install -y gnupg curl

curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt-get update

sudo apt-get install -y mongodb-org

sudo systemctl daemon-reload

sudo systemctl start mongod

sudo systemctl status mongod

sudo systemctl enable mongod

mongosh redirect --eval 'db.createCollection("first"); db.createCollection("second"); db.createCollection("third")'

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
mongosh redirect --eval "use('hello-world')"
mongosh redirect --eval 'db.createUser(
  {
    user: "myNormalUser",
    pwd: "xyz123",
    roles: [ { role: "readWrite", db: "hello-world" },
             { role: "read", db: "admin" } ],
    mechanisms: ["SCRAM-SHA-1"]
  }
)'



db.runCommand({updateUser: "dude", pwd: "dude", mechanisms: ["SCRAM-SHA-1"]})
mongosh redirect --eval 'db.posts.find()'

wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-x86_64-100.11.0.tgz

tar -xvzf mongodb-database-tools-ubuntu2204-x86_64-100.11.0.tgz

cd mongodb-database-tools-ubuntu2204-x86_64-100.11.0

sudo cp bin/* /usr/bin/

cd /var/tmp

tee mongo-backup.sh << EOF
#!/bin/bash

# Make sure to:
# 1) Name this file 'backup.sh' and place it in /home/ubuntu
# 2) Run sudo apt-get install awscli to install the AWSCLI
# 3) Run aws configure (enter s3-authorized IAM user and specify region)
# 4) Fill in DB HOSTNAME + name
# 5) Create S3 bucket for the backups and fill it in below (set a lifecycle rule to expire files older than X days in the bucket)
# 6) Run chmod +x backup.sh
# 7) Test it out via ./backup.sh
# 8) Set up a daily backup at midnight via 'crontab -e':
#    0 0 * * * /home/ubuntu/backup.sh > /home/ubuntu/backup.log

# DB host (secondary preferred as to avoid impacting primary performance)
HOST=localhost

# DB name
export DBNAME=${mongo_db_name}

# S3 bucket name
export BUCKET=${iteration}

# Linux user account
export BACKUP_USER=$USER

# Current time
export TIME=$(printf '%(%Y-%m-%d-%H%M%S)T')

# Backup directory
export DEST=/home/home/tmp

# Tar file of backup directory
export TAR=$DEST/../$TIME.tar

# Create backup dir (-p to avoid warning if already exists)
/bin/mkdir -p /home/ubuntu/tmp

# Log
export ARCHIVE_NAME=$(printf '%(%Y-%m-%d-%H%M%S)T')
echo "Backing up $HOSTNAME/${mongo_db_name} to s3://$iteration/ at $ARCHIVE_NAME";

# Dump from mongodb HOSTNAME into backup directory
/usr/bin/mongodump --port 27017 -o /home/ubuntu/tmp

# Create tar of backup directory
/bin/tar cvf $ARCHIVE_NAME.tar.gz /home/ubuntu/tmp/


# Upload tar to s3
/usr/bin/aws s3 cp $TAR s3://$iteration/

# Remove tar file locally
/bin/rm -f $ARCHIVE_NAME

# Purge the old data
/bin/rm -rf /home/ubuntu/tmp/*

# All done
echo "Backup available at https://s3.amazonaws.com/${iteration}/$ARCHIVE_NAME.tar.gz"
EOF


sudo chmod +x /var/tmp/mongo-backup.sh




# Install OMZ
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# sudo omz update

echo END
