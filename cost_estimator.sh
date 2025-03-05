import boto3
import json

# Set AWS region for Mumbai
AWS_REGION = "ap-south-1"

# Initialize AWS clients
ec2_client = boto3.client("ec2", region_name=AWS_REGION)
rds_client = boto3.client("rds", region_name=AWS_REGION)
pricing_client = boto3.client("pricing", region_name="us-east-1")  # Pricing API works only in us-east-1

# Function to fetch hourly price of an instance type
def get_instance_price(instance_type, service):
    try:
        response = pricing_client.get_products(
            ServiceCode=service,
            Filters=[
                {"Type": "TERM_MATCH", "Field": "instanceType", "Value": instance_type},
                {"Type": "TERM_MATCH", "Field": "location", "Value": "Asia Pacific (Mumbai)"}
            ],
        )
        price_info = json.loads(response["PriceList"][0])
        price_details = list(price_info["terms"]["OnDemand"].values())[0]["priceDimensions"]
        hourly_price = float(list(price_details.values())[0]["pricePerUnit"]["USD"])
        return hourly_price
    except Exception as e:
        print(f"⚠️ Warning: Could not fetch price for {instance_type}. Error: {e}")
        return 0  # Return 0 if price not found

# Fetch running EC2 instances
ec2_instances = ec2_client.describe_instances(Filters=[{"Name": "instance-state-name", "Values": ["running"]}])
ec2_list = []

for reservation in ec2_instances["Reservations"]:
    for instance in reservation["Instances"]:
        instance_id = instance["InstanceId"]
        instance_type = instance["InstanceType"]
        hourly_price = get_instance_price(instance_type, "AmazonEC2")
        monthly_cost = round(hourly_price * 24 * 30, 2)  # Convert hourly price to monthly estimate
        ec2_list.append((instance_id, instance_type, monthly_cost))

# Fetch running RDS instances
rds_instances = rds_client.describe_db_instances()
rds_list = []

for rds in rds_instances["DBInstances"]:
    db_id = rds["DBInstanceIdentifier"]
    db_type = rds["DBInstanceClass"]
    hourly_price = get_instance_price(db_type, "AmazonRDS")
    monthly_cost = round(hourly_price * 24 * 30, 2)  # Convert hourly price to monthly estimate
    rds_list.append((db_id, db_type, monthly_cost))

# Calculate total estimated monthly cost
total_ec2_cost = sum(cost for _, _, cost in ec2_list)
total_rds_cost = sum(cost for _, _, cost in rds_list)
total_cost = total_ec2_cost + total_rds_cost

# Save results to a text file
with open("aws_cost_estimate.txt", "w") as file:
    file.write("AWS Cost Estimation (Mumbai Region)\n\n")

    if ec2_list:
        file.write("EC2 Instances:\n")
        for instance_id, instance_type, cost in ec2_list:
            file.write(f"- {instance_id} | {instance_type} | ${cost}/month\n")
    else:
        file.write("No running EC2 instances found.\n")

    file.write("\n")

    if rds_list:
        file.write("RDS Databases:\n")
        for db_id, db_type, cost in rds_list:
            file.write(f"- {db_id} | {db_type} | ${cost}/month\n")
    else:
        file.write("No running RDS databases found.\n")

    file.write(f"\nTotal Estimated Monthly Cost: ${total_cost}\n")

# Print output file content
with open("aws_cost_estimate.txt", "r") as file:
    print(file.read())
