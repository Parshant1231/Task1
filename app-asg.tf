# Launch Template
resource "aws_launch_template" "app" {
    name_prefix     = "${local.name_prefix}-app"
    image_id        = data.aws_ami.ubuntu.id
    instance_type   =  var.instance_type
    key_name        = var.key_name

    vpc_security_group_ids = [aws_security_group.app.id]

    user_data = filebase64("user_data.sh")
}

#ASG
resource "aws_autoscaling_group" "app" {
    desired_capacity  = 2
    max_size          = 4
    min_size          = 2

    vpc_zone_identifier = aws_subnet.private_app[*].id

    launch_template {
        id      = aws_launch_template.app.id
        version = "$Latest"
    }
}