# namespace -> devopsdojo (app_name)
resource "kubernetes_namespace" "app_ns" {
    metadata {
        name = var.app_name
        labels = {
            "kubernetes.io/metadata.name" = var.app_name
        }
    }
}

# database secrets
resource "kubernetes_secret" "db_secrets" {
    metadata {
        name      = "db-secrets"
        namespace = kubernetes_namespace.app_ns.metadata[0].name
    }

    data = {
        DATABASE_URL = "postgresql://${var.db_default_settings.db_admin_username}:${random_password.rds_password.result}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
        SECRET_KEY   = random_password.backend_secret_key.result
        DB_PASSWORD = random_password.rds_password.result
    }

    type = "Opaque"
}

# application configmap
resource "kubernetes_config_map" "app_config" {
    metadata {
        name      = "app-config"
        namespace = kubernetes_namespace.app_ns.metadata[0].name
    }

    data = {
        FLASK_DEBUG = "1"
        DB_NAME     = aws_db_instance.postgres.db_name
        DB_HOST     = aws_db_instance.postgres.address
        DB_PORT     = tostring(aws_db_instance.postgres.port)
        DB_USER     = var.db_default_settings.db_admin_username
    }
}

# external database service
resource "kubernetes_service" "external_db_service" {
    metadata {
        name      = "${var.app_name}-db-service"
        namespace = kubernetes_namespace.app_ns.metadata[0].name
    }

    spec {
        type          = "ExternalName"
        external_name = aws_db_instance.postgres.address
    }
}

# servicename: devopsdozo-db-service 
# namespace: devopsdozo
# dns name: ServiceName.Namespace.svc.cluster.local
# full dns: devopsdozo-db-service.devopsdozo.svc.cluster.local  



