resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.0.1.0/24"
}

resource "random_password" "admin_password" {
    length = 16
    count = var.instance_count
    special = true
  
}

resource "aws_instance" "VM" {
    count = var.instance_count
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.main_subnet.id
    security_groups = [aws_security_group.main_sg.name]



    tags = {
        Name = "VM-${count.index}"
  }

    user_data = file("ping_script.sh")

    //admin_password = random_password.admin_password[count.index].result

    key_name = aws_key_pair.ssh_key.key_name

}

resource "aws_key_pair" "ssh_key" {
    key_name = "ssh_key"
    public_key = file(var.public_key_path)

  
}

resource "null_resource" "ping_test" {
  count = var.instance_count

  provisioner "file" {
    source      = "ping_script.sh"
    destination = "/tmp/ping_script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ping_script.sh",
      "echo '${join(" ", aws_instance.VM[*].private_ip)}' > /tmp/instance_ips.txt",
      "/tmp/ping_script.sh",
      "cat /tmp/ping_results.log"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.VM[count.index].public_ip
    }
  }

  depends_on = [aws_instance.VM]
}