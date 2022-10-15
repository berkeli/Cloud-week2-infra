output "ip" {
  value = aws_eip_association.main.public_ip
}
