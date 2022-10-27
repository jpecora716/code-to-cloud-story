data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "codetocloud" {
  ami         = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  tags = {
    Name      = "jpecora-private-instance"
    Env       = "Prod"
  }
  network_interface {
    network_interface_id = aws_network_interface.demo_nic.id
    device_index         = 0
  }
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "demo_vpc"
  }
}

resource "aws_subnet" "demo_subnet" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "demo_subnet"
  }
}

resource "aws_network_interface" "demo_nic" {
  subnet_id   = aws_subnet.demo_subnet.id
  security_groups = [aws_security_group.demo_ssh.id]
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "demo_network_interface"
  }
}

resource "aws_security_group" "demo_ssh" {
  name        = "demo_allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    description      = "Demo - Allow SSH From Anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "demo_allow_ssh"
  }
}