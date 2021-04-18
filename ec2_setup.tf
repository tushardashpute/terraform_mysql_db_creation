data "aws_ami" "amazon-linux-2" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "aws_instance" "mysql_db" {
  count = 1
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_mysql.id]
  tags = {
    Name = "ansible_inventory_mysql_db_${count.index + 1}"
  }
}

resource "null_resource" "copy_execute" {
    count = 1
    connection {
        type = "ssh"
        host = aws_instance.mysql_db[count.index].public_ip
        user = "ec2-user"
        private_key = file("C://Users//TUSHAR//Downloads//mysql.pem")
    }

    provisioner "file" {
        source      = "mysql_setup_script.sh"
        destination = "/tmp/mysql_setup_script.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod 777 /tmp/mysql_setup_script.sh",
            "sh /tmp/mysql_setup_script.sh",
        ]
    }

    depends_on = [ aws_instance.mysql_db ]  
}