# Terraform Configuration for Infracost CLI Testing
# This configuration creates common AWS resources to test cost estimation

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# EC2 Instance - t3.medium
# This creates a t3.medium EC2 instance for general purpose computing
# t3.medium instances provide 2 vCPUs and 4GB RAM
# Cost: ~$30-40/month depending on usage and discounts
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = "t3.medium"
  
  tags = {
    Name        = "Infracost-Test-Instance"
    Environment = "test"
  }
  
  # Optional: Add user data to simulate a web server
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
}

# RDS Database Instance - PostgreSQL db.t3.micro
# This creates a small PostgreSQL database for testing purposes
# db.t3.micro provides 1 vCPU and 1GB RAM, eligible for free tier
# Cost: ~$15-20/month for the instance (storage and backups additional)
resource "aws_db_instance" "test_db" {
  identifier = "infracost-test-db"
  
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  
  # For testing purposes - use a simple password
  # In production, always use AWS Secrets Manager or Parameter Store
  username = "admin"
  password = "testpassword123"
  
  # Managed storage (no need to provision)
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = false
  
  # Multi-AZ disabled for cost testing
  multi_az = false
  
  # Backup retention (7 days is minimum for cost comparison)
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Public access disabled (more secure and realistic)
  publicly_accessible = false
  
  tags = {
    Name        = "Infracost-Test-Database"
    Environment = "test"
  }
}

# S3 Bucket
# This creates a standard S3 bucket for storing files
# Costs are primarily based on storage volume and data transfer
# Cost: ~$0.023/GB/month for storage, plus request costs
resource "aws_s3_bucket" "test_bucket" {
  bucket = "infracost-test-bucket-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "Infracost-Test-Bucket"
    Environment = "test"
  }
}

# Generate a random suffix for the bucket name to ensure uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Optional: S3 Bucket Versioning (additional cost)
# This enables versioning, which increases storage costs
resource "aws_s3_bucket_versioning" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Optional: S3 Bucket with lifecycle policy
# Add a lifecycle rule to transition objects to cheaper storage classes
resource "aws_s3_bucket_lifecycle_configuration" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id
  
  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}