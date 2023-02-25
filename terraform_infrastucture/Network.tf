resource "aws_vpc" "osos-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "osos-vpc"
  }
}

# -----------------------------------------public-sub------------------------------------
resource "aws_subnet" "osos-pub1" {
  vpc_id     = aws_vpc.osos-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sub1"
    "kubernetes.io/cluster/osos-eks-cluster" = "owned"
    "kubernetes.io/role/internal-elb" = 1
  }
}
resource "aws_subnet" "osos-pub2" {
  vpc_id     = aws_vpc.osos-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sub2"
    "kubernetes.io/cluster/osos-eks-cluster" = "owned"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# -----------------------------------------private-sub------------------------------------
resource "aws_subnet" "osos-pv1" {
  vpc_id     = aws_vpc.osos-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1a"
  tags = {
    Name = "private-sub1"
    "kubernetes.io/cluster/osos-eks-cluster" = "owned"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "osos-pv2" {
  vpc_id     = aws_vpc.osos-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-1c"
  tags = {
    Name = "private-sub2"
    "kubernetes.io/cluster/osos-eks-cluster" = "owned"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# -----------------------------------------"internet-gw"------------------------------------
resource "aws_internet_gateway" "os-gw" {
  vpc_id = aws_vpc.osos-vpc.id

  tags = {
    Name = "eks-gw"
  }
}

# -----------------------------------------"pub-rout-table"------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.osos-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.os-gw.id
  }

  tags = {
    Name = "osos-rw"
  }
}

# -----------------------------------------"nat-gw"-------------------------------------------------

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.osos-pub1.id
  tags = {
    Name = "eks--nat-gw"
  }
}

# -----------------------------------------"private-rout-table"------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.osos-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "osos-rw-private"
  }
}

# -----------------------------------------"rout-table-association"------------------------------------
resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.osos-pub1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.osos-pub2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pv1" {
  subnet_id      = aws_subnet.osos-pv1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "pv2" {
  subnet_id      = aws_subnet.osos-pv2.id
  route_table_id = aws_route_table.private.id
}

# --------------------------------------"EC2-Bastion"-----------------------------

resource "aws_instance" "bastion" {
  ami = "ami-0d50e5e845c552faf"
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.osos-pub1.id
  key_name                    = "nagato"
  vpc_security_group_ids      = [aws_security_group.eks.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.my_instance_profile1.id
  tags = {
    Name = "jumphost"
  }

}

resource "aws_iam_instance_profile" "my_instance_profile1" {
  name = "my-ec2-instance-profile1"

  role = aws_iam_role.osos-node.id
  # aws_iam_role.my_role.name

}


# --------------------------------------"aws_security_group"-----------------------------
resource "aws_security_group" "eks" {
  name        = "eks-sec-group"
  description = "Allow HTTP traffic from anywhere"
  vpc_id = aws_vpc.osos-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
