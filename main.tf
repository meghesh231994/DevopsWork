# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  # Change this to your desired region
}

# Data source to get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get the default subnet in the first availability zone
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${data.aws_vpc.default.region}a"
  default_for_az    = true
}

# Create a security group
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

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

# Create EC2 instances
resource "aws_instance" "example" {
  count                  = 3
  ami                    = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI, update as needed
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "Example-Instance-${count.index + 1}"
  }
}

# Output the public IPs of the instances
output "instance_public_ips" {
  value = aws_instance.example[*].public_ip
}
