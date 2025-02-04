resource "aws_security_group" "mongo_app" {
  vpc_id = module.vpc.vpc_id
  name = "mongo-app-${local.owner_email}"

  tags = {
    Name = "mongo-app-${local.owner_email}"
    User = "${local.owner_email}"
  }
}

resource "aws_security_group" "mongo_backup" {
  vpc_id = module.vpc.default_vpc_id
  name = "mongo-backup-${local.owner_email}"

  tags = {
    Name = "mongo-backup-${local.owner_email}"
    User = "${local.owner_email}"
  }
}

resource "aws_security_group" "allow_https" {
  name        = "dev_allow_tls"
  description = "Allow HTTP/TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "dev"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb-sg-dev"
  }
}