# Create a local Route 53 hosted zone in LocalStack
resource "aws_route53_zone" "oyindamola" {
  name = "oyindamola.gq"
}

# Create the wildcard certificate
resource "aws_acm_certificate" "oyindamola" {
  domain_name       = "*.oyindamola.gq"
  validation_method = "DNS"
}

# DNS validation record
resource "aws_route53_record" "oyindamola" {
  for_each = {
    for dvo in aws_acm_certificate.oyindamola.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.oyindamola.zone_id
}

# Create record for tooling
resource "aws_route53_record" "tooling" {
  zone_id = aws_route53_zone.oyindamola.zone_id
  name    = "tooling.oyindamola.gq"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb[0].dns_name
    zone_id                = aws_lb.ext-alb[0].zone_id
    evaluate_target_health = true
  }
}

# Create record for wordpress
resource "aws_route53_record" "wordpress" {
  zone_id = aws_route53_zone.oyindamola.zone_id
  name    = "wordpress.oyindamola.gq"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb[0].dns_name
    zone_id                = aws_lb.ext-alb[0].zone_id
    evaluate_target_health = true
  }
}