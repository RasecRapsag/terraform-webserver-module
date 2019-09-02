data "aws_availability_zones" "all" {
  state = "available"
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.id
    availability_zones   = data.aws_availability_zones.all.names

    min_size = var.min_size
    max_size = var.max_size

    load_balancers    = [aws_elb.example.name]
    health_check_type = "ELB"

    tag {
        key                 = "Name"
        value               = var.cluster_name
        propagate_at_launch = true
    }

    tag {
        key                 = "Version"
        value               = "v0.0.2"
        propagate_at_launch = true
    }
}

resource "aws_launch_configuration" "example" {
    image_id      = "ami-02a3447be1ec3a38f"
    instance_type = var.instance_type
    security_groups = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF
    
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-instance"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Load Balancer
resource "aws_elb" "example" {
    name               = var.cluster_name
    security_groups    = [aws_security_group.elb.id]
    availability_zones = data.aws_availability_zones.all.names

    # Checagem da saúde das instâncias
    health_check {
        target              = "HTTP:${var.server_port}/"
        interval            = 30
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    # Listener
    listener {
        lb_port           = 80
        lb_protocol       = "http"
        instance_port     = var.server_port
        instance_protocol = "http"
    }
}

resource "aws_security_group" "elb" {
    name = "${var.cluster_name}-elb"

    # Libera saída
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Libera entrada na porta 80 para Internet
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["179.209.168.55/32"]
    }
}
