provider "aws" {
  region = "us-east-1" 
}

# Upload SSH Public Key
resource "aws_key_pair" "deployer" {
  key_name   = "cloud_project_key"
  public_key = file("~/.ssh/cloud_project_key.pub")
}

# Enable security groups to open ports 22 and 80
resource "aws_security_group" "web_sg" {
  name        = "allow_web_ssh"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# Deploy an Ubuntu Linux VM
resource "aws_instance" "web" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS for us-east-1
  instance_type = "t3.micro"              
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Install NGINX and disable internal firewall
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install nginx -y
              sudo ufw disable
              EOF

  tags = {
    Name = "NGINX-Student-Portal"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}