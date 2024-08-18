# Generate a random ID for the S3 bucket name suffix
resource "random_id" "s3_bucket_suffix" {
  byte_length = 8
}

# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(var.tags, {
    "Name" : "main-vpc"
  })
}

# Create a public subnet in Availability Zone ap-south-1a
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    "Name" : "public-subnet-az1"
  })
}

# Create a public subnet in Availability Zone ap-south-1b
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    "Name" : "public-subnet-az2"
  })
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(var.tags, {
    "Name" : "main-igw"
  })
}

# Create a route table for the public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = merge(var.tags, {
    "Name" : "public-route-table"
  })
}

# Associate the route table with the first public subnet
resource "aws_route_table_association" "public_subnet_az1_association" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate the route table with the second public subnet
resource "aws_route_table_association" "public_subnet_az2_association" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a security group for the EC2 instances
resource "aws_security_group" "ec2_security_group" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "Security group for EC2 instances"
  name        = "ec2-sg"

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" : "ec2-sg"
  })
}

# Create an S3 bucket with a unique name
resource "aws_s3_bucket" "app_s3_bucket" {
  bucket = "app-bucket-${random_id.s3_bucket_suffix.hex}"
  tags = merge(var.tags, {
    "Name" : "app-bucket"
  })
}

# Launch the first EC2 instance in the first public subnet
resource "aws_instance" "ec2_instance_1" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnet_az1.id
  security_groups = [aws_security_group.ec2_security_group.id]
  user_data       = base64encode(file("user_data_instance_1.sh"))
  tags = merge(var.tags, {
    "Name" : "ec2-instance-1"
  })
}

# Launch the second EC2 instance in the second public subnet
resource "aws_instance" "ec2_instance_2" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnet_az2.id
  security_groups = [aws_security_group.ec2_security_group.id]
  user_data       = base64encode(file("user_data_instance_2.sh"))
  tags = merge(var.tags, {
    "Name" : "ec2-instance-2"
  })
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_security_group.id]
  subnets            = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
  tags = merge(var.tags, {
    "Name" : "app-lb"
  })
}

# Create a target group for the ALB
resource "aws_lb_target_group" "app_lb_target_group" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

  tags = merge(var.tags, {
    "Name" : "app-tg"
  })
}

# Attach the first EC2 instance to the target group
resource "aws_lb_target_group_attachment" "tg_attachment_1" {
  target_group_arn = aws_lb_target_group.app_lb_target_group.arn
  target_id        = aws_instance.ec2_instance_1.id
  port             = 80
}

# Attach the second EC2 instance to the target group
resource "aws_lb_target_group_attachment" "tg_attachment_2" {
  target_group_arn = aws_lb_target_group.app_lb_target_group.arn
  target_id        = aws_instance.ec2_instance_2.id
  port             = 80
}

# Create a listener for the ALB
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.app_lb_target_group.arn
    type             = "forward"
  }
}

# Output the DNS name of the Load Balancer
output "load_balancer_dns_name" {
  value = aws_lb.app_lb.dns_name
}
