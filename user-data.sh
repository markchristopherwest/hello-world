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
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl daemon-reload
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl enable mongod

cd /var/tmp

# download files necessary for mongo backup
wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-x86_64-100.11.0.tgz
tar -xvzf mongodb-database-tools-ubuntu2204-x86_64-100.11.0.tgz
cd mongodb-database-tools-ubuntu2204-x86_64-100.11.0
sudo cp bin/* /usr/bin/

# create the mongo-setup.js
tee /var/tmp/mongo-setup.js << EOF
db.createCollection("first"); db.createCollection("second"); db.createCollection("third");
use('hello_world');
db.createUser({
  user: "${mongo_username}",
  pwd: "${mongo_password}",
  roles: [ { role: "readWrite", db: "${mongo_database}" },
    { role: "readWrite", db: "admin" } ],
  mechanisms: ["SCRAM-SHA-1", "SCRAM-SHA-256"]
});
EOF

mongosh --file mongo-setup.js

tee /var/tmp/mongo-backup.sh << EOF
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
export DBNAME=${mongo_database}
# S3 bucket name
export BUCKET=${iteration}
# Linux user account
export BACKUP_USER=$USER
# Current time
export TIME=$(printf '%(%Y-%m-%d-%H%M%S)T')
# Backup directory
export DEST=/home/home/tmp
# Tar file of backup directory
export TAR="$DEST/../$TIME.tar"
# Create backup dir (-p to avoid warning if already exists)
/bin/mkdir -p /home/ubuntu/tmp
# Log
export ARCHIVE_NAME=$(printf '%(%Y-%m-%d-%H%M%S)T'.tar.gz)
echo "Backing up $HOSTNAME/${mongo_database} to s3://${iteration}/ from /home/ubuntu/tmp";
# Dump from mongodb HOSTNAME into backup directory
/usr/bin/mongodump --port 27017 -o /home/ubuntu/tmp
# Create tar of backup directory
sudo /bin/tar cvf $ARCHIVE_NAME /home/ubuntu/tmp/

# Upload tar to s3
/usr/bin/aws s3 cp $TIME.tar s3://${iteration}/

# Remove tar file locally
sudo /bin/rm -f $ARCHIVE_NAME

# Purge the old data
sudo /bin/rm -rf /home/ubuntu/tmp/*

# All done
echo "Backup available at https://s3.amazonaws.com/${iteration}/$ARCHIVE_NAME"

EOF

# make the backup script executable
sudo chmod +x /var/tmp/mongo-backup.sh

# copy the backup script from /var/tmp to the user directory
sudo cp /var/tmp/mongo-backup.sh /home/ubuntu

# sed the mongod.conf in etc to listen on all interfaces
sudo sed -i 's/127.0.0.1/::,0.0.0.0/g' /etc/mongod.conf
sudo systemctl restart mongod

# run first backup job
/home/ubuntu/mongo-backup.sh
# add backup job to crotab and run every 15 minutes
(crontab -l 2>/dev/null; echo "*/30 * * * * /home/ubuntu/mongo-backup.sh") | crontab -

# Install OMZ
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# sudo omz update
echo END
