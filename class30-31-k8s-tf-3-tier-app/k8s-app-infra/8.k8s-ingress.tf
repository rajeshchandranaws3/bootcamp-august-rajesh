#### ingress ns setup

# HTTPS/SSL Ingress Configuration with TLS termination
# This creates an ALB with SSL certificate and HTTP to HTTPS redirect
resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = kubernetes_namespace.app_ns.metadata[0].name

    annotations = {
      # Create an internet-facing ALB (public access)
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"

      # Use IP mode for better compatibility with Fargate and pod networking
      "alb.ingress.kubernetes.io/target-type" = "ip"

      # Health check path - ALB will check this endpoint for service health
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"

      # SSL/TLS Configuration
      # Listen on both HTTP (80) and HTTPS (443) ports
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"

      # Automatically redirect HTTP traffic to HTTPS
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"

      # SSL Security Policy - ensures strong encryption
      "alb.ingress.kubernetes.io/ssl-policy" = "ELBSecurityPolicy-TLS-1-2-2017-01"

      # AWS ACM Certificate ARN - replace with your certificate ARN
      # NOTE: Ensure this certificate covers your domain and is in the correct AWS region
      "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate.cert.arn

      # HTTP to HTTPS redirect action configuration
      # "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": {\"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
    }
  }

  spec {
    # Use the ALB ingress class
    ingress_class_name = "alb"

    # TLS configuration for certificate management
    tls {
      hosts = ["devopsdojo.rajeshapps.site"]
    }

    # Single subdomain rule - all traffic for devopsdojo.rajeshapps.site
    rule {
      host = "devopsdojo.rajeshapps.site"

      http {
        # Route API calls to backend service (must come first for priority)
        path {
          path      = "/api"
          path_type = "Prefix"

          backend {
            service {
              name = "backend"
              port {
                number = 8000
              }
            }
          }
        }

        # Route all other traffic to frontend
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.app_ns,
    aws_acm_certificate.cert
  ]
}