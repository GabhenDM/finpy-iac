# public subnet
resource "aws_subnet" "public_subnet_az1" {
  depends_on = [
    aws_vpc.vpc,
  ]

  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.0.0/24"

  availability_zone_id = "sae1-az1"

  tags = {
    Name = "public-subnet"
  }

  map_public_ip_on_launch = true
}

# private subnet
resource "aws_subnet" "private_subnet_az1" {
  depends_on = [
    aws_vpc.vpc,
  ]

  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"

  availability_zone_id = "sae1-az1"

  tags = {
    Name = "private-subnet"
  }
}

# public subnet
resource "aws_subnet" "public_subnet_az2" {
  depends_on = [
    aws_vpc.vpc,
  ]

  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.4.0/24"

  availability_zone_id = "sae1-az3"

  tags = {
    Name = "public-subnet"
  }

  map_public_ip_on_launch = true
}

# private subnet
resource "aws_subnet" "private_subnet_az2" {
  depends_on = [
    aws_vpc.vpc,
  ]

  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.3.0/24"

  availability_zone_id = "sae1-az3"

  tags = {
    Name = "private-subnet"
  }
}

# internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [
    aws_vpc.vpc,
  ]

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

#Public Gateway NAT subnet
resource "aws_route_table" "IG_route_table" {
  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.internet_gateway,
  ]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "IG-route-table"
  }
}

# associate route table to public subnet
resource "aws_route_table_association" "associate_routetable_to_public_subnet_az1" {
  depends_on = [
    aws_subnet.public_subnet_az1,
    aws_route_table.IG_route_table,
  ]
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.IG_route_table.id
}

resource "aws_route_table_association" "associate_routetable_to_public_subnet_az2" {
  depends_on = [
    aws_subnet.public_subnet_az1,
    aws_route_table.IG_route_table,
  ]
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.IG_route_table.id
}


## Private Subnet NAT Gateway
# elastic ip
resource "aws_eip" "elastic_ip_az1" {
  vpc      = true
}

resource "aws_eip" "elastic_ip_az2" {
  vpc      = true
}

# NAT gateway
resource "aws_nat_gateway" "nat_gateway_az1" {
  depends_on = [
    aws_subnet.public_subnet_az1,
    aws_eip.elastic_ip_az1,
  ]
  allocation_id = aws_eip.elastic_ip_az1.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  tags = {
    Name = "nat-gateway az1"
  }
}

resource "aws_nat_gateway" "nat_gateway_az2" {
  depends_on = [
    aws_subnet.public_subnet_az2,
    aws_eip.elastic_ip_az2,
  ]
  allocation_id = aws_eip.elastic_ip_az2.id
  subnet_id     = aws_subnet.public_subnet_az2.id

  tags = {
    Name = "nat-gateway az2"
  }
}

# route table with target as NAT gateway
resource "aws_route_table" "NAT_route_table_az1" {
  depends_on = [
    aws_vpc.vpc,
    aws_nat_gateway.nat_gateway_az1,
  ]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway_az1.id
  }

  tags = {
    Name = "NAT-route-table"
  }
}

# associate route table to private subnet
resource "aws_route_table_association" "associate_routetable_to_private_subnet_az1" {
  depends_on = [
    aws_subnet.private_subnet_az1,
    aws_route_table.NAT_route_table_az1,
  ]
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.NAT_route_table_az1.id
}

resource "aws_route_table" "NAT_route_table_az2" {
  depends_on = [
    aws_vpc.vpc,
    aws_nat_gateway.nat_gateway_az2,
  ]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway_az2.id
  }

  tags = {
    Name = "NAT-route-table"
  }
}

# associate route table to private subnet
resource "aws_route_table_association" "associate_routetable_to_private_subnet_az2" {
  depends_on = [
    aws_subnet.private_subnet_az2,
    aws_route_table.NAT_route_table_az2,
  ]
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.NAT_route_table_az2.id
}