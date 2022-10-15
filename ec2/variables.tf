variable "name" {
  description = "Name of the EC2 instance"
  default     = "api-2"
}

variable "subnet_id" {
  description = "Subnet ID to use"
}

variable "sg_id" {
  description = "Security group ID to use"
}

variable "docker_run_command" {
  description = "Docker run command"
}
