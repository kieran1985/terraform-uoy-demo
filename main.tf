// TEST BUCKET 1
resource "aws_s3_bucket" "test-bucket" {
  bucket = "test-interview-bucket-f3m7x1l3"
  tags = {
    name = "test-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "test-bucket-ownership" {
  bucket = aws_s3_bucket.test-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "test-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.test-bucket-ownership]

  bucket = aws_s3_bucket.test-bucket.id
  acl    = "private"
}

// RDS INSTANCE

resource "random_password" "test_db_master_password" {
  length  = 16
  special = true
}

# Store the password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "test_db_password_secret" {
  name = "rds/test-master-password"
}

resource "aws_secretsmanager_secret_version" "test_db_password_version" {
  secret_id = aws_secretsmanager_secret.test_db_password_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.test_db_master_password.result
  })
}

# Create RDS instance
resource "aws_db_instance" "test_rds_instance" {
  identifier             = "my-rds-instance"
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_encrypted      = true
  username               = "admin"
  password               = random_password.test_db_master_password.result
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
}

# Security Group for RDS
resource "aws_security_group" "db_sg" {
  name_prefix = "rds-sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = ["subnet-02c9ab9a2e063d6bf", "subnet-0b2ce1291bf6cc8d1", "subnet-0730f7c8f9d74a8a2"] # Replace with your subnet IDs
}
