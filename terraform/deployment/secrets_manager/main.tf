# Creating the PostgreSQL password secret in AWS Secrets Manager

resource "aws_secretsmanager_secret" "postgres_secret" {
  name = "${var.environment}-${var.postgres_secret_name}"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "postgres_secret_version" {
  secret_id     = aws_secretsmanager_secret.postgres_secret.id
  secret_string = random_password.postgres_password.result
}

resource "random_password" "postgres_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>?"
}
