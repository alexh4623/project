variable "aws_region" {
    description = "region"
    default = "eu-west-1"
  
}

variable "instance_count" {
    description = "Number of EC2 instances"
    default = 3
  
}

variable "instance_type" {
    description = "Type of the instance"
    default = "t2.micro"
  
}

variable "public_key_path" {
  description = "Path to the SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to the SSH private key"
  default     = "~/.ssh/id_rsa"
}
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  default     = "ami-0b995c42184e99f98"
}