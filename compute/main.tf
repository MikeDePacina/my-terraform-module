locals {
  median_num_of_private_instances = (var.max_num_of_private_instances + var.min_num_of_private_instances) / 2
  median_num_of_public_instances  = (var.max_num_of_public_instances + var.min_num_of_public_instances) / 2
}

resource "aws_launch_template" "private_vm_template" {
  name_prefix = "private-vm-"
  image_id    = data.aws_ami.ubuntu.id


  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price          = "0.03"
      spot_instance_type = "one-time"
    }
  }

  instance_type = "t2.micro"

  vpc_security_group_ids = [var.private_sg_id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "public_vm_template" {
  name_prefix = "public-vm-"
  image_id    =  data.aws_ami.ubuntu.id 



  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price          = "0.03"
      spot_instance_type = "one-time"
    }

  }

  instance_type = "t2.micro"

  vpc_security_group_ids = [var.public_sg_id]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "private_vms" {

  min_size         = var.min_num_of_private_instances
  max_size         = var.max_num_of_private_instances
  desired_capacity = local.median_num_of_private_instances

  vpc_zone_identifier = var.private-subnet-ids

  launch_template {
    id      = aws_launch_template.private_vm_template.id
    version = "$Latest"
  }
}


resource "aws_autoscaling_group" "public_vms" {
  min_size         = var.min_num_of_public_instances
  max_size         = var.max_num_of_public_instances
  desired_capacity = local.median_num_of_public_instances

  vpc_zone_identifier = var.public-subnet-ids

  launch_template {
    id      = aws_launch_template.public_vm_template.id
    version = "$Latest"
  }
}
