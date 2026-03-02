resource "aws_db_subnet_group" "db" {
    subnet_ids = aws_subnet.private_db[*].id

    name = lower("${local.name_prefix}-db-subnet")
}

resource "aws_db_instance" "mysql" {
    identifier         = lower("${local.name_prefix}-db")
    engine             = "mysql"
    instance_class     = "db.t3.micro"
    allocated_storage  = 20
    db_name            = var.db_name
    username           = var.db_username
    password           = var.db_password

    multi_az           = true
    publicly_accessible = false

    db_subnet_group_name    = aws_db_subnet_group.db.name
    vpc_security_group_ids = [aws_security_group.rds.id]

    skip_final_snapshot =  true
}

