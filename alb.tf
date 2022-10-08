resource "aws_lb" "sbcntrAlbInternal" {
  name               = "sbcntr-alb-internal"
  internal           = true
  load_balancer_type = "application"

  subnets = [
    aws_subnet.sbcntrSubnetPrivateContainer1a.id,
    aws_subnet.sbcntrSubnetPrivateContainer1c.id,
  ]

  security_groups = [
    aws_security_group.sbcntrSgInternal.id,
  ]

  tags = {
    Name = "sbcntr-alb-internal"
  }
}

resource "aws_lb_target_group" "sbcntrTgSbcntrdemoBlue" {
  name        = "sbcntr-tg-sbcntrdemo-blue"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.sbcntrVpc.id

  health_check {
    path                = "/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200

  }
}

resource "aws_lb_target_group" "sbcntrTgSbcntrdemoGreen" {
  name        = "sbcntr-tg-sbcntrdemo-green"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.sbcntrVpc.id

  health_check {
    path                = "/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200

  }
}

resource "aws_lb_listener" "sbcntrLisnerSbcntrdemoBlue" {
  load_balancer_arn = aws_lb.sbcntrAlbInternal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sbcntrTgSbcntrdemoBlue.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }

}

resource "aws_lb_listener" "sbcntrLisnerSbcntrdemoGreen" {
  load_balancer_arn = aws_lb.sbcntrAlbInternal.arn
  port              = "10080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sbcntrTgSbcntrdemoGreen.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }

}
