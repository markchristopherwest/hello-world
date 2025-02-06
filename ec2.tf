resource "tls_private_key" "demo_ec2_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_id" "demo_ec2_ssh_key_pair_name" {
  prefix      = "hello-world-"
  byte_length = 4
}

resource "aws_key_pair" "demo_ec2_ssh_key_pair" {
  key_name   = random_id.demo_ec2_ssh_key_pair_name.dec
  public_key = tls_private_key.demo_ec2_ssh_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.demo_ec2_ssh_key_pair.key_name}.pem"
  content = tls_private_key.demo_ec2_ssh_key.private_key_pem
  file_permission = "0400"
}


# Create an IAM role for the mongo_s3 Servers.
resource "aws_iam_role" "mongo_s3_iam_role" {
    name = "mongo_s3_iam_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "mongo_s3_instance_profile" {
    name = "mongo_s3_instance_profile"
    role = aws_iam_role.mongo_s3_iam_role.name
}

resource "aws_iam_role_policy" "mongo_s3_iam_role_policy" {
  name = "mongo_s3_iam_role_policy"
  role = "${aws_iam_role.mongo_s3_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${random_pet.example.id}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${random_pet.example.id}/*"]
    }
  ]
}
EOF
}



resource "aws_instance" "mongo" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = "subnet-0fc40bb00d2b7e817"
  associate_public_ip_address = true
  key_name               = aws_key_pair.demo_ec2_ssh_key_pair.key_name
  vpc_security_group_ids = [
    # module.eks.cluster_security_group_id, 
    aws_security_group.mongo.id,
  ]

  tags = merge({
    "User" : local.owner_email
  })

  user_data = base64gzip(templatefile("${path.module}/user-data.sh", {
    iteration = "${random_pet.example.id}"
    mongo_username = "mongo"
    mongo_password = "mongo"
    mongo_db_name = "hello-world"
    
  }))

  root_block_device {
    volume_type = "gp3"
  }

    iam_instance_profile = "${aws_iam_instance_profile.mongo_s3_instance_profile.id}"
  # lifecycle {
  #   ignore_changes = all
  # }

}
