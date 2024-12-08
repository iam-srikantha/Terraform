provider "aws" {
  region = "ap-east-1"

}

//VPC creation
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
}

//Subnet Creation
resource "aws_subnet" "demo_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "demo_subnet"
  }
}

//IGW creation
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo_igw"
  }
}

//Route table creation
resource "aws_route_table" "demo_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "demo_rt"
  }
}

//Subnet Association
resource "aws_route_table_association" "demo_sub_rt_association" {
  subnet_id      = aws_subnet.demo_subnet.id
  route_table_id = aws_route_table.demo_rt.id
}

//Security Group creation
resource "aws_security_group" "demo_vpc_sg" {
  name        = "demo_vpc_sg"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "demo_vpc_sg"
  }
}

//Instance Creation
resource "aws_instance" "demo-server" {
  ami = ""
  key_name = "demo-key"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.demo_subnet.id
  vpc_security_group_ids = [aws_security_group.demo_vpc_sg.id]
}
