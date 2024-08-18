variable "region" {
  default = "ap-south-1"
  description = "Region for aws infrastructure"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "CIDR for vpc"
}

variable "tags" {
  type = map(string)
  default = {
    "Environment" = "dev"
    "Project": "tf-alb-ec2"
  }
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Type of AWS EC2 instance"
}

variable "ami" {
  type        = string
  default     = "ami-0ec0e125bb6c6e8ec"
  description = "ami of aws ec2 instance"
}