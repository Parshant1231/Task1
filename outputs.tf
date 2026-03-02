output "bastion_public_ip" {
    value = aws_instance.bastion.public_ip
}

output "rds_endpoint" {
    value = aws_db_instance.mysql.endpoint
}