resource "aws_security_group" "bastion" {
    vpc_id = aws_vpc.main.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["152.58.78.73/32"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "TCP"
        cidr_blocks  = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "app"{
    name   = "${local.name_prefix}-app-sg"
    vpc_id = aws_vpc.main.id

    # Allow SSH from Bastion only
    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "TCP" 
        security_groups = [aws_security_group.bastion.id]
    }
 
    # Allow HTTP from Bastion (or ALB later)
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "TCP"
        security_groups = [aws_security_group.bastion.id]
    }

    # Allow general outbound (for updates via NAT)
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${local.name_prefix}-app-sg"
    }
}

# RDS Security Group

resource "aws_security_group" "rds" {
    name   = "${local.name_prefix}-rds-sg"
    vpc_id = aws_vpc.main.id

    ingress {
        description     = "MySQL from App"
        from_port       = 3306
        to_port         = 3306
        protocol        = "TCP"
        security_groups = [aws_security_group.app.id]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${local.name_prefix}-rds-sg"
    }
}