# Infracost CLI Test Configuration

This Terraform configuration creates common AWS resources for testing Infracost CLI cost estimation features.

## Resources Included

1. **EC2 Instance (t3.medium)**
   - General purpose compute instance
   - 2 vCPUs, 4GB RAM
   - Includes basic web server setup via user data

2. **RDS Database (PostgreSQL db.t3.micro)**
   - Small PostgreSQL database for testing
   - 1 vCPU, 1GB RAM
   - 20GB allocated storage with backup retention

3. **S3 Bucket**
   - Standard S3 bucket with versioning enabled
   - Includes lifecycle policy for cost optimization
   - Configured for automatic transition to cheaper storage classes

## Cost Estimation

You can run Infracost to see estimated monthly costs:

```bash
infracost breakdown --path .
```

## Prerequisites

- Terraform installed
- AWS CLI configured (for actual deployment if needed)
- Infracost CLI installed

## Cost Breakdown

Expected monthly costs (approximate):
- EC2 t3.medium: ~$30-40/month
- RDS db.t3.micro: ~$15-20/month  
- S3 bucket: ~$2-5/month (depending on usage)

**Total estimated monthly cost: ~$50-65/month**

## Notes

- Configuration uses us-east-1 region
- Some settings are simplified for testing (e.g., hardcoded password)
- In production, use AWS Secrets Manager and Parameter Store
- RDS instance uses single-AZ for cost testing
- S3 includes versioning and lifecycle policies for realistic cost scenarios