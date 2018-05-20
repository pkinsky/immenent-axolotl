
provider "aws" {
  region = "us-west-2"
  shared_credentials_file = "/home/pk/.aws/credentials"
  profile = "default"
}

resource "aws_iam_role" "example" {
  name = "imminent-axolotl-tf-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cd-instance-role" {
  name = "imminent-axolotl-tf-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cd-instance-policy" {
  name = "imminent-axolotl-tf-instance-policy"
  role = "${aws_iam_role.cd-instance-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "cd-instance-profile" {
  name = "imminent-axolotl-instance-profile-policy"
  role = "${aws_iam_role.cd-instance-role.name}"
}


resource "aws_iam_role_policy" "example" {
  name = "imminent-axolotl-tf-policy"
  role = "${aws_iam_role.example.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:EnableMetricsCollection",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribePolicies",
                "autoscaling:DescribeScheduledActions",
                "autoscaling:DescribeNotificationConfigurations",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:SuspendProcesses",
                "autoscaling:ResumeProcesses",
                "autoscaling:AttachLoadBalancers",
                "autoscaling:PutScalingPolicy",
                "autoscaling:PutScheduledUpdateGroupAction",
                "autoscaling:PutNotificationConfiguration",
                "autoscaling:PutLifecycleHook",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DeleteAutoScalingGroup",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:TerminateInstances",
                "tag:GetTags",
                "tag:GetResources",
                "sns:Publish",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeInstanceHealth",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_codedeploy_app" "example" {
  name = "imminent-axolotl-tf"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = "${aws_codedeploy_app.example.name}"
  deployment_group_name = "imminent-axolotl-tf"
  service_role_arn      = "${aws_iam_role.example.arn}"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }


  ec2_tag_set {
    ec2_tag_filter {
      key = "Name"
      type = "KEY_AND_VALUE"
      value = "imminent-axolotl-tf"
    } 
  }

  load_balancer_info {
    elb_info {
      name = "${aws_lb.example.name}"
    }
  }
}


# basically just cargo culted from demo example created stuff
resource "aws_instance" "example-1" {
  ami           = "ami-fde96b9d"
  instance_type = "t2.micro"

  vpc_security_group_ids    = ["${aws_security_group.example.id}"]

  # needed, probably, for s3 access
  iam_instance_profile = "${aws_iam_instance_profile.cd-instance-profile.name}"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install ruby",
      "sudo apt-get -y install wget",
      "wget https://aws-codedeploy-us-west-2.s3.amazonaws.com/latest/install",
      "chmod +x install",
      "sudo ./install auto",
      "rm install",
      "aws s3 cp s3://imminent-axolotl/keter.deb .",
      "sudo dpkg -i keter.deb",
      "rm keter.deb",
      "sudo systemctl enable keter",
      "sudo systemctl start keter"
    ]

    connection {
      type     = "ssh"
      user     = "admin"
      private_key =  "${file("/home/pk/dev/keys/imminent-axolotl.pem")}"
    }
  }

  key_name = "imminent-axolotl"

  tags {
    Name = "imminent-axolotl-tf"
  }
}

# resource "aws_instance" "example-2" {
#   ami           = "ami-1b3b462b"
#   instance_type = "t1.micro"

#   vpc_security_group_ids    = ["${aws_security_group.example.id}"]

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum -y update",
#       "sudo yum -y install ruby",
#       "sudo yum -y install wget",
#       "wget https://aws-codedeploy-us-west-2.s3.amazonaws.com/latest/install",
#       "chmod +x install",
#       "sudo ./install auto"
#     ]

#     connection {
#       type     = "ssh"
#       user     = "ec2-user"
#       private_key =  "${file("/home/pk/dev/keys/imminent-axolotl.pem")}"
#     }
#   }


#   # needed, probably, for s3 access
#   iam_instance_profile = "${aws_iam_instance_profile.cd-instance-profile.name}"

#   key_name = "imminent-axolotl"

#   tags {
#     Name = "imminent-axolotl-tf"
#   }
# }


resource "aws_lb" "example" {
  name               = "imminent-axolotl-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.example.id}"]
  #subnets           = ["${aws_subnet.subnet-a.id}", "${aws_subnet.subnet-c.id}"]
  subnets            = ["${data.aws_subnet_ids.example.ids}"]
}


resource "aws_lb_target_group" "example" {
  name     = "imminent-axolotl-tf-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.main.id}"
}


# resource "aws_lb_target_group_attachment" "example-2" {
#   target_group_arn = "${aws_lb_target_group.example.arn}"
#   target_id        = "${aws_instance.example-2.id}"
#   port             = 80
# }

resource "aws_lb_target_group_attachment" "example-1" {
  target_group_arn = "${aws_lb_target_group.example.arn}"
  target_id        = "${aws_instance.example-1.id}"
  port             = 80
}


resource "aws_lb_listener" "http-example" {
  load_balancer_arn = "${aws_lb.example.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.example.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "https-example" {
  load_balancer_arn = "${aws_lb.example.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "arn:aws:acm:us-west-2:009632620577:certificate/2cc54110-24de-4bd8-99c7-cec43da50ec5"

  default_action {
    target_group_arn = "${aws_lb_target_group.example.arn}"
    type             = "forward"
  }
}


resource "aws_security_group" "example" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# TODO: create this inline instead of hardcoding as default?
variable "vpc_id" {
  description = "magic value for vpc id"
  default = "vpc-0d2a0374"
}

data "aws_vpc" "main" {
  id = "${var.vpc_id}"
}


data "aws_subnet_ids" "example" {
  vpc_id = "${var.vpc_id}"
}


# even more stuff (r53)


resource "aws_route53_record" "www-hiki" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www.hikikomorphism.com"
  type    = "A"

  alias {
    name                   = "${aws_lb.example.dns_name}"
    zone_id                = "${aws_lb.example.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "hiki" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "hikikomorphism.com"
  type    = "A"

  alias {
    name                   = "${aws_lb.example.dns_name}"
    zone_id                = "${aws_lb.example.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "primary" {
  name = "hikikomorphism.com"
}
