# Cloud-Native-Microservices-Deployment-and-Monitoring

Welcome! This is my project that demonstrates how to build, deploy, and monitor cloud-native microservices using Terraform and AWS. As someone passionate about cloud computing and automation, this repository reflects my journey in learning and implementing infrastructure as code (IaC) and containerized deployments.

# Project Overview
This project creates a scalable infrastructure on AWS using Terraform. It deploys a containerized application (NGINX in this case) on Amazon ECS (Fargate), all while adhering to best practices for security, automation, and scalability.

## Key features include:

- Setting up a VPC with public and private subnets.
- Configuring an ECS Cluster and deploying services using the Fargate launch type.
- Managing roles, policies, and security groups for controlled access.
- Logging and monitoring using AWS CloudWatch for better observability.
## Why I Built This
I’ve always been intrigued by the power of cloud-native technologies. This project allowed me to:

1. Learn the ins and outs of Terraform and AWS services.
2. Practice building production-ready infrastructure.
3. Create a foundation for deploying microservices that can be scaled and monitored effectively.

## How to Use This Repository
### Prerequisites
- Terraform (v1.0 or higher)
- AWS CLI (configured with appropriate credentials)
- A basic understanding of AWS services like ECS, CloudWatch, and VPCs.
## Steps to Deploy
1. Clone the repository:

`git clone https://github.com/Swaroop1769/Cloud-Native-Microservices-Deployment-and-Monitoring.git`

2. Navigate to the project directory:


`cd Cloud-Native-Microservices-Deployment-and-Monitoring`

3. Initialize Terraform:


`terraform init`

4. Plan and apply the changes:


`terraform plan`

`terraform apply`

5. Confirm with yes when prompted.

Access the deployed service via the load balancer URL or the public IP of the ECS task.

## What I Learned
- How to design cloud architecture using Terraform for seamless automation.
- Setting up IAM roles and policies to ensure secure deployments.
- Logging and monitoring with AWS CloudWatch for troubleshooting and insights.
- Deploying containerized applications in production-like environments using AWS ECS (Fargate).
## Challenges Faced
### Some of the challenges I encountered were:

- Understanding the integration between ECS services and networking configurations.
- Debugging errors related to IAM role permissions and Terraform state files.
- Future Improvements
- Add auto-scaling to handle dynamic traffic loads.
- Replace the NGINX container with a real microservice application.
- Implement more robust monitoring with custom CloudWatch metrics and alarms.
# Connect With Me
If you find this project helpful or want to discuss similar topics, feel free to connect with me:

[LinkedIn](linkedin.com/in/sai-swaroop-rayaprolu-b275501a7)
