# id аккаунта (AWS account ID)
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
# id пользователя (AWS user ID)
output "user_id" {
  value = data.aws_caller_identity.current.user_id
}
# AWS регион, который используется в данный момент
output "region" {
  value = data.aws_region.current.name
}
