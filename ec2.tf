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


resource "aws_instance" "mongo" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = "subnet-063d122f42897e29b"
  associate_public_ip_address = true
  key_name               = aws_key_pair.demo_ec2_ssh_key_pair.key_name
  vpc_security_group_ids = [
    # module.eks.cluster_security_group_id, 
    aws_security_group.mongo.id,
  ]

  tags = merge({
    "User" : local.owner_email
  })

  user_data = templatefile("${path.module}/user-data.sh", {
    mongo_username = "mongo"
    mongo_password = "mongo"
  })

  root_block_device {
    volume_type = "gp3"
  }

  # lifecycle {
  #   ignore_changes = all
  # }

}
