
# bastion host security group
resource "aws_security_group" "sg_bastion_host" {
  depends_on = [
    aws_vpc.vpc,
  ]
  name        = "sg bastion host"
  description = "bastion host security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet_az1.cidr_block]
  }
    egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet_az2.cidr_block]
  }
}

# bastion host ec2 instance
resource "aws_instance" "bastion_host" {
    depends_on = [
    aws_security_group.sg_bastion_host,
    ]
    ami = "ami-089aac6323aa08aee"
    instance_type = "t2.micro"
    key_name = "desktop-primary"
    vpc_security_group_ids = [aws_security_group.sg_bastion_host.id]
    subnet_id = aws_subnet.public_subnet_az1.id
    tags = {
        Name = "bastion host"
  }
    provisioner "file" {
        source      = "~/.ssh/desktop-primary.pem"
        destination = "/home/ec2-user/desktop-primary.pem"

        connection {
        type     = "ssh"
        user     = "ec2-user"
        private_key = file("~/.ssh/desktop-primary.pem")
        host     = aws_instance.bastion_host.public_ip
    }
  }

}