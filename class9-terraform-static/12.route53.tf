# create a public hosted zone or use an existing one
data "aws_route53_zone" "primary" {
  # name         = "akhileshmishra.tech"  # replace with your domain
  name         = "rajeshapps.site"
  private_zone = false
}

# resource "aws_route53_zone" "primary" {
#   name = "rajeshapps.site"
# }


# create a record set for the ALB in the hosted zone
resource "aws_route53_record" "august_alb" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "august.${data.aws_route53_zone.primary.name}"
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# ACM certificate for the domain (us-east-1 region)
resource "aws_acm_certificate" "cert" {
  domain_name       = "august.${data.aws_route53_zone.primary.name}"
  validation_method = "DNS"

}

# Route53 record for ACM validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# ACM cert validation using DNS
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
