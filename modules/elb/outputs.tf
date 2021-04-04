output "default_target_group" {
  value       = aws_lb_target_group.default_lb_gt.id
  description = "Target Group for the default Listener rule"
}

output "target_groups" {
  value = tomap({
    for k, v in aws_lb_target_group.tgs : k => v.arn
  })
  description = "Key value target group corresponding for the key in the rules variable"
}

output "domain" {
  value = aws_route53_record.route.name
}
