output "role_name" {
    value = aws_iam_role.lambda.name
}

output "label_context" {
  value       = module.lambda_label.context
  description = "Context of this module to pass to other label modules"
}
