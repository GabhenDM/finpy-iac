provider "aws" {
    profile = "default"
    region = "sa-east-1"
}




resource "aws_security_group" "finpy-sg" {
  depends_on = [
    aws_vpc.vpc,
  ]

  name        = "finpy-sg"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow TCP AZ1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet_az1.cidr_block]
  }
    ingress {
    description = "allow TCP AZ2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet_az2.cidr_block]
  }
  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks= [aws_subnet.public_subnet_az1.cidr_block]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "finpy-backend1" {
    ami = "ami-0041df06adb8d15e6"
    instance_type = "t2.micro"
    key_name = "desktop-primary"
    vpc_security_group_ids = [aws_security_group.finpy-sg.id]
    subnet_id = aws_subnet.private_subnet_az1.id
    associate_public_ip_address= false
}

resource "aws_instance" "finpy-backend2" {
    ami = "ami-0041df06adb8d15e6"
    instance_type = "t2.micro"
    key_name = "desktop-primary"
    vpc_security_group_ids = [aws_security_group.finpy-sg.id]
    subnet_id = aws_subnet.private_subnet_az2.id
    associate_public_ip_address= false

}

# output "finpy-backend1-ip-addr" {
#   value = { aws_instance.finpy-backend1.public_ip}
# }


# output "finpy-backend2-ip-addr" {
#   value = { aws_instance.finpy-backend2.public_ip}
# }

