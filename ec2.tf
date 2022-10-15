module "api-2" {
  source             = "./ec2"
  name               = "api-2"
  subnet_id          = aws_subnet.public.id
  sg_id              = aws_security_group.main.id
  docker_run_command = "sudo docker run -dp 5001:5001 --restart unless-stopped berkeli/week2-api2:latest"
}

module "api-1" {
  source             = "./ec2"
  name               = "api-1"
  subnet_id          = aws_subnet.public.id
  sg_id              = aws_security_group.main.id
  docker_run_command = "sudo docker run -dp 5000:5000 -e API2_URL=https://${module.api-2.ip} --restart unless-stopped berkeli/week2-api1:latest"
}


module "app" {
  source             = "./ec2"
  name               = "app"
  subnet_id          = aws_subnet.public.id
  sg_id              = aws_security_group.main.id
  docker_run_command = "sudo docker run -dp 80:8080 --restart unless-stopped berkeli/week2-app:latest"
}

