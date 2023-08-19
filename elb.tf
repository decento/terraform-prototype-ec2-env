resource "aws_lb" "alb01" {
  name               = "alb01"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_alb.id]
  subnets = [
    aws_subnet.public1a.id,
    aws_subnet.public1b.id,
    aws_subnet.public1c.id
  ]
  access_logs {
    bucket  = aws_s3_bucket.elb_access_logs.bucket
    prefix  = ""
    enabled = true
  }

}

resource "aws_lb_target_group" "alb01_tg01" {
  name     = "alb01-tg01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    enabled = true
    path    = "/index.html"
    port    = 80
  }
}

resource "aws_lb_target_group_attachment" "alb01_tg01_web" {
  for_each         = aws_instance.web
  target_group_arn = aws_lb_target_group.alb01_tg01.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "alb0_listener01" {
  load_balancer_arn = aws_lb.alb01.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb01_tg01.arn
  }
}

resource "aws_security_group" "allow_alb" {
  name        = "allow_alb"
  description = "Allow ALB inbound"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "InboundWeb80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description     = "ToWeb80"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_web.id]
  }
  tags = {
    Name = "allow_alb"
  }
}


#### Storing access logs #####

# we create a bucket to store access logs
resource "random_id" "rand" {
  byte_length = 8
}
resource "aws_s3_bucket" "elb_access_logs" {
  bucket = "tf-prototype-ec2-env-access-logs--${random_id.rand.hex}"
}

resource "aws_s3_bucket_policy" "elb_access_logs_policy" {
  bucket = aws_s3_bucket.elb_access_logs.id
  policy = data.aws_iam_policy_document.elb_access_logs_allow_logwrites.json
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}


# bucket policy to allow the ELB service account to put files into our bucket
data "aws_iam_policy_document" "elb_access_logs_allow_logwrites" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.elb_access_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      aws_s3_bucket.elb_access_logs.arn
    ]
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.elb_access_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.elb_access_logs.arn]
  }
}

