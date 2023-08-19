resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "default_gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}


resource "aws_route_table" "igw_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_gw.id
  }
  tags = {
    Name = "main-igw-public-rt"
  }
}

resource "aws_subnet" "public1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-Public-1A"
  }
}

resource "aws_route_table_association" "public1a" {
  subnet_id      = aws_subnet.public1a.id
  route_table_id = aws_route_table.igw_public.id
}




resource "aws_subnet" "public1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-Public-1B"
  }
}

resource "aws_route_table_association" "public1b" {
  subnet_id      = aws_subnet.public1b.id
  route_table_id = aws_route_table.igw_public.id
}


resource "aws_subnet" "public1c" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-Public-1C"
  }
}

resource "aws_route_table_association" "public1c" {
  subnet_id      = aws_subnet.public1c.id
  route_table_id = aws_route_table.igw_public.id
}


resource "aws_subnet" "private1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "main-Private-1A"
  }
}

resource "aws_subnet" "private1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "main-Private-1B"
  }
}

resource "aws_subnet" "private1c" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "main-Private-1C"
  }
}


# nat gw
resource "aws_eip" "default_nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "default_nat_gw" {
  allocation_id = aws_eip.default_nat_gw_eip.id
  subnet_id     = aws_subnet.public1a.id
  tags = {
    Name = "main-nat-gw"
  }
  depends_on = [aws_internet_gateway.default_gw]
}

resource "aws_route_table" "nat_gw_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.default_nat_gw.id
  }
  tags = {
    Name = "main-nat-gw-private-rt"
  }
}

resource "aws_route_table_association" "private1a" {
  subnet_id      = aws_subnet.private1a.id
  route_table_id = aws_route_table.nat_gw_private.id
}
resource "aws_route_table_association" "private1b" {
  subnet_id      = aws_subnet.private1b.id
  route_table_id = aws_route_table.nat_gw_private.id
}
resource "aws_route_table_association" "private1c" {
  subnet_id      = aws_subnet.private1c.id
  route_table_id = aws_route_table.nat_gw_private.id
}

