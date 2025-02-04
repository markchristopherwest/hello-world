resource "aws_lb" "example" {
  name               = random_pet.example.id
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.allow_https.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "http" {
  name        = "eks-dev-http"
  target_type = "instance"
  port        = "30080"
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path     = "/"
    port     = "30080"
    protocol = "HTTP"
    matcher  = "200,404"
  }

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "https" {
  name        = "eks-dev-https"
  target_type = "instance"
  port        = "30443"
  protocol    = "HTTPS"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path     = "/"
    port     = "30443"
    protocol = "HTTPS"
    matcher  = "200,404"
  }

  tags = {
    Environment = "dev"
  }
}

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.example.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.http.arn
#   }
# }

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.example.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   certificate_arn   = module.eks.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.https.arn
#   }
# }