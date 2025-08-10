output "jenkins_instance_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_server.public_ip
  sensitive   = false
}

output "jenkins_url" {
  description = "URL to access Jenkins web interface"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "ssh_connection_command" {
  description = "SSH connection command for the Jenkins server"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.jenkins_server.public_ip}"
}

# --- Infrastructure Metadata ---
output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.jenkins_sg.id
}

output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.jenkins_server.id
}

output "instance_az" {
  description = "Availability Zone where the instance is deployed"
  value       = aws_instance.jenkins_server.availability_zone
}

# --- Status Outputs ---
output "instance_state" {
  description = "Current state of the EC2 instance"
  value       = aws_instance.jenkins_server.instance_state
}

output "instance_launch_time" {
  description = "Time when instance was launched"
  value       = aws_instance.jenkins_server.launch_time
}

# --- Verification Outputs ---
output "docker_installation_check" {
  description = "Command to verify Docker installation"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.jenkins_server.public_ip} 'docker --version'"
}

output "jenkins_service_status" {
  description = "Command to check Jenkins service status"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.jenkins_server.public_ip} 'sudo systemctl status jenkins'"
}

# --- Secure Outputs (Sensitive) ---
output "initial_jenkins_admin_password_command" {
  description = "Command to retrieve initial Jenkins admin password (run on server)"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.jenkins_server.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
  sensitive   = true
}

output "terraform_state_reminder" {
  description = "Important reminder about Terraform state"
  value       = <<EOT
  [Important] Your Terraform state contains sensitive information.
  Store it securely and never commit .tfstate files to version control.
  EOT
}