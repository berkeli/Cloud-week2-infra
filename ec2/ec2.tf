resource "aws_instance" "api" {
  ami                         = "ami-06672d07f62285d1d"
  instance_type               = "t2.micro"
  key_name                    = "Berkeli"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_id]

  tags = {
    Name = var.name
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/Berkeli.pem")
    host        = coalesce(self.public_ip, self.private_ip)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install docker -y",
      "sudo usermod -a -G docker ec2-user",
      "sudo systemctl enable docker.service",
      "sudo systemctl start docker.service",
      var.docker_run_command,
    ]
  }
}

resource "aws_eip" "ip" {
  vpc = true
}

resource "aws_eip_association" "main" {
  instance_id   = aws_instance.api.id
  allocation_id = aws_eip.ip.id
}
