resource "aws_security_group" "finpy-alb-sg" {
  name        = "finpy-alb-sg"
  description = "finpy-alb-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet_az1.cidr_block]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet_az2.cidr_block]
  }
  tags = {
    Name = "finpy"
  }
}

resource "aws_alb_target_group" "finpy_alb_target_group" {
  name     = "finpy-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  depends_on = [
    aws_vpc.vpc,
  ]
}

resource "aws_alb" "finpy-alb" {
  name               = "finpy-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.finpy-alb-sg.id]
  subnets            = [aws_subnet.public_subnet_az1.id,aws_subnet.public_subnet_az2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }

  depends_on = [
    aws_security_group.finpy-alb-sg,
    aws_subnet.public_subnet_az1,
  ]
}

resource "aws_lb_target_group_attachment" "finpy-backend1" {
  target_group_arn = aws_alb_target_group.finpy_alb_target_group.arn
  target_id        = aws_instance.finpy-backend1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "finpy-backend2" {
  target_group_arn = aws_alb_target_group.finpy_alb_target_group.arn
  target_id        = aws_instance.finpy-backend2.id
  port             = 80
}

resource "aws_alb_listener" "finpy_alb_listener" {
  load_balancer_arn = aws_alb.finpy-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.finpy_alb_target_group.id
    type             = "forward"
  }

  depends_on = [
    aws_alb.finpy-alb,
    aws_alb_target_group.finpy_alb_target_group
  ]
}