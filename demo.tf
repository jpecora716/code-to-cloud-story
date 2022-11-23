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
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  tags = {
    Name      = "jpecora-private-instance"
    Env       = "Prod"
    Owner     = "Team"
    git_org   = "jpecora716"
    git_repo  = "code-to-cloud-story"
    yor_trace = "809fda6e-47bc-4599-838f-9e339fc0e9df"
  }
  network_interface {
    network_interface_id = aws_network_interface.demo_nic.id
    device_index         = 0
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_instance" "codetocloud" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  tags = {
    Name      = "jpecora-missing-tags"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name      = "demo_vpc"
    Owner     = "Team"
    git_org   = "jpecora716"
    git_repo  = "code-to-cloud-story"
    yor_trace = "078a4a35-626e-4713-bbaf-b5e9166cfff6"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    Owner     = "Team"
    git_org   = "jpecora716"
    git_repo  = "code-to-cloud-story"
    yor_trace = "ec49ed2d-bb11-45f2-8c76-e6887988d14c"
  }
}

resource "aws_subnet" "demo_subnet" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name      = "demo_subnet"
    Owner     = "Team"
    git_org   = "jpecora716"
    git_repo  = "code-to-cloud-story"
    yor_trace = "b295b073-9064-42c4-884f-fd59b6455f9f"
  }
}

resource "aws_network_interface" "demo_nic" {
  subnet_id       = aws_subnet.demo_subnet.id
  security_groups = [aws_security_group.demo_ssh.id]
  private_ips     = ["172.16.10.100"]

  tags = {
    Name      = "demo_network_interface"
    Owner     = "Team"
    git_org   = "jpecora716"
    git_repo  = "code-to-cloud-story"
    yor_trace = "09ef0a6d-fab4-4272-9491-455c83b89536"
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
    Name      = "demo_allow_ssh"
    Owner     = "Team"
    git_org   = "jpecora716"
    git_repo  = "code-to-cloud-story"
    yor_trace = "aadddb38-71e2-4860-be52-fdd24f09f18b"
  }
}
