# Data source for latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical, Ubuntu's publisher

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Jenkins Master EC2 Instance
resource "aws_instance" "jenkins_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = "skz"

  vpc_security_group_ids = [aws_security_group.jenkins.id]
  subnet_id              = aws_subnet.public[0].id

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "Jenkins Master"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Elastic IP for Jenkins Master
resource "aws_eip" "jenkins_master" {
  instance = aws_instance.jenkins_master.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-jenkins-master-eip"
    Environment = var.environment
  }
}