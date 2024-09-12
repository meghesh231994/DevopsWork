# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  # Change this to your desired region
}

# Define variables
variable "instance_type" {
  default = "t2.medium"  # Adjust instance type as needed
}

variable "ami_id" {
  default = "ami-0e86e20dae9224db8"  # Amazon Linux 2 AMI, update as needed
}

# Create a security group
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
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

  tags = {
    Name = "allow_ssh_http"
  }
}

# Create SonarQube EC2 instance
resource "aws_instance" "sonarqube" {
  ami           = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "SonarQube-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Install SonarQube
              # Add your SonarQube installation commands here
              EOF
}

# Create Test EC2 instance
resource "aws_instance" "test" {
  ami           = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "Test-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Configure Test server
              # Add your Test server configuration commands here
              EOF
}

# Create Nexus EC2 instance
resource "aws_instance" "nexus" {
  ami           = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "Nexus-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Install Nexus
              # Add your Nexus installation commands here
              EOF
}

# Output the public IPs of the instances
output "sonarqube_public_ip" {
  value = aws_instance.sonarqube.public_ip
}

output "test_public_ip" {
  value = aws_instance.test.public_ip
}

output "nexus_public_ip" {
  value = aws_instance.nexus.public_ip
}
