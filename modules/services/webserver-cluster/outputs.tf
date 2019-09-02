output "asg_name" {
    description = "Nome do ASG (Auto Scaling Group)"
    value       = aws_autoscaling_group.example.name
}

output "clb_dns_name" {
    description = "O nome do domínio do Load balancer"
    value       = aws_elb.example.dns_name
}
