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

# Приватный ip ec2-инстанса
output "private_ip" {
  value = aws_instance.netology-ec2.*.private_ip
}
# Публичный ip ec2-инстанса
output "public_ip" {
  value = aws_instance.netology-ec2.*.public_ip
}
# Идентификатор (id) подсети в которой создан инстанс
output "subnet_id" {
  value = aws_instance.netology-ec2.*.subnet_id
}