provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "gitlab_key" {
  key_name   = "gitlab_keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "gitlab_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "gitlab_vpc"
  }
}

resource "aws_internet_gateway" "gitlab_igw" {
  vpc_id = aws_vpc.gitlab_vpc.id

  tags = {
    Name = "gitlab_igw"
  }
}

resource "aws_subnet" "gitlab_subnet" {
  vpc_id     = aws_vpc.gitlab_vpc.id  
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table" "gitlab_route_table" {
  vpc_id = aws_vpc.gitlab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gitlab_igw.id
  }

  tags = {
    Name = "gitlab_route_table"
  }
}

resource "aws_route_table_association" "gitlab_rta" {
  subnet_id      = aws_subnet.gitlab_subnet.id
  route_table_id = aws_route_table.gitlab_route_table.id
}

resource "aws_security_group" "gitlab_sg" {
  vpc_id      = aws_vpc.gitlab_vpc.id
  name        = "gitlab_sg"
  description = "Allow inbound traffic for GitLab"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For SSH
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For HTTP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For HTTPS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}

resource "aws_instance" "gitlab_server" {
  ami           = "ami-02675d30b814d1daa"
  instance_type = "t2.medium"
  key_name               = aws_key_pair.gitlab_key.key_name
  vpc_security_group_ids = [aws_security_group.gitlab_sg.id]
    subnet_id              = aws_subnet.gitlab_subnet.id

  tags = {
    Name = "GitLab Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y curl openssh-server ca-certificates
              curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
              apt-get install -y gitlab-ce
              EOF
}


resource "aws_eip" "gitlab_eip" {
  instance = aws_instance.gitlab_server.id
}

output "gitlab_ip" {
  value = aws_eip.gitlab_eip.public_ip
}
