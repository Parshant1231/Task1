data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"]

    filter {
        name    = "name"
        values  = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter {
        name    = "virtualization-type"
        values  = ["hvm"]
    }
}

resource "aws_instance" "bastion" {
    ami             = data.aws_ami.ubuntu.id
    instance_type   = var.instance_type
    subnet_id       = aws_subnet.public[0].id
    key_name        = var.key_name

    vpc_security_group_ids = [aws_security_group.bastion.id]

    associate_public_ip_address = true

    tags = {
        Name = "${local.name_prefix}-bastion"
    }
}