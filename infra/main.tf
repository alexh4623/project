resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
}

resource "aws_security_group" "main_sg" {
  name        = "main_sg"
  description = "Allow ICMP traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "random_password" "admin_password" {
    length = 16
    count = var.instance_count
    special = true
  
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = tls_private_key.ssh_key.public_key_openssh
}


data "template_file" "user_data" {
  count = var.instance_count

  template = <<-EOF
              #!/bin/bash
              echo "admin:${random_password.admin_password[count.index].result}" | chpasswd
              EOF
}

resource "aws_instance" "VM" {
    count = var.instance_count
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.main_subnet.id
    //security_groups   = [aws_security_group.main_sg.name]
    vpc_security_group_ids = [aws_security_group.main_sg.id]


    tags = {
        Name = "VM-${count.index}"
  }

    user_data = data.template_file.user_data[count.index].rendered

  key_name = aws_key_pair.deployer.key_name

  provisioner "file" {
    source      = "ping_script.sh"
    destination = "/tmp/ping_script.sh"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.public_ip
    }
  }

  /*provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ping_script.sh",
      "echo '${join(" ", aws_instance.VM.*.private_ip)}' > /tmp/instance_ips.txt",
      "/tmp/ping_script.sh",
      "cat /tmp/ping_results.log"
    ]

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.public_ip
    }
  }*/
  depends_on = [
    aws_security_group.main_sg,
    aws_key_pair.deployer,
    aws_ssm_parameter.admin_password,
  ]
}

resource "aws_ssm_parameter" "admin_password" {
  count = var.instance_count

  name  = "admin_password_${count.index}"
  type  = "SecureString"
  value = random_password.admin_password[count.index].result
}