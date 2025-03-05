# AWS Cost Estimation Script

This script calculates the **monthly cost** of running **EC2** and **RDS** instances in the **Mumbai (ap-south-1) AWS region**. It retrieves pricing from the AWS Pricing API and saves the output to a text file.

## 🚀 Features
✅ **Estimates monthly cost** of running EC2 & RDS instances  
✅ **Uses AWS Pricing API** to fetch real-time pricing data  
✅ **Writes formatted output** to `aws_cost_estimate.txt`  
✅ **Handles missing pricing data gracefully**  
✅ **Skips sections if no instances are found**  

## 📌 Prerequisites
- **AWS CLI** installed and configured (`aws configure`)
- **Boto3 Python package** installed:
  ```bash
  pip install boto3

IAM Role or User must have the following permissions:
ec2:DescribeInstances
rds:DescribeDBInstances
pricing:GetProducts (for fetching instance costs)

🛠️ Setup

Clone the repository
git clone https://github.com/singhvishal10/AWS_cost_estimator
cd AWS_cost_estimator

Install dependencies
pip install -r requirements.txt

Run the script
python aws_cost_estimator.py



📄 Output Example

After running, the estimated monthly cost is saved in aws_cost_estimate.txt. Example output:


AWS Cost Estimation (Mumbai Region)
EC2 Instances:
- i-0abcdef1234567890 | t3.micro | $9.50/month

RDS Databases:
- mydatabase | db.t3.micro | $13.00/month

Total Estimated Monthly Cost: $22.50




⚠️ Known Issues

If your IAM role does not have pricing:GetProducts permissions, the script will return $0 for pricing.
AWS Pricing API only works in us-east-1, so prices are fetched from there even if instances are in ap-south-1.
