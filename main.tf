# AWS provider configuration
provider "aws" {
  region = "us-east-1" # Set your preferred AWS region here
}

# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16" # Define the IP range for the VPC
  enable_dns_support   = true          # Enable DNS resolution for the VPC
  enable_dns_hostnames = true          # Enable DNS hostnames for instances in this VPC

  tags = {
    Name = "main-vpc" # Tag the VPC for identification
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24" # Define the subnet's IP range
  map_public_ip_on_launch = true          # Ensure instances get public IPs
  availability_zone       = "us-east-1a"  # Specify the AZ for the subnet

  tags = {
    Name = "public-subnet" # Tag the subnet for identification
  }
}

# Create a private subnet within the VPC
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24" # Define the private subnet's IP range
  availability_zone = "us-east-1a"  # Specify the AZ for the subnet

  tags = {
    Name = "private-subnet" # Tag the subnet for identification
  }
}

# Create an Internet Gateway for internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id # Attach to the main VPC

  tags = {
    Name = "internet-gateway" # Tag the IGW for identification
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id # Attach to the main VPC

  # Define the route to the internet through the internet gateway
  route {
    cidr_block = "0.0.0.0/0"                 # Route all traffic to the internet
    gateway_id = aws_internet_gateway.igw.id # Use the created IGW
  }

  tags = {
    Name = "public-route-table" # Tag the route table
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id  # Associate with the public subnet
  route_table_id = aws_route_table.public_rt.id # Link to the public route table
}

# Create an ECS Cluster for managing microservices
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "microservices-cluster" # Name the ECS cluster

  tags = {
    Name = "ECS-Cluster" # Tag the ECS cluster
  }
}

# Define IAM Role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role" # Name the IAM role

  # Define trust policy allowing ECS tasks to assume the role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com" # ECS tasks can assume the role
        }
        Action = "sts:AssumeRole" # Allow ECS to assume the role
      }
    ]
  })

  tags = {
    Name = "ECS-Task-Execution-Role" # Tag the IAM role
  }
}

# Attach the ECS Task Execution Policy to the IAM role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name                               # Attach to the ECS task execution role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" # Use AWS managed policy
}

# Create a Security Group for ECS tasks
resource "aws_security_group" "ecs_security_group" {
  name   = "ecs-security-group" # Name the security group
  vpc_id = aws_vpc.main_vpc.id  # Attach to the VPC

  # Allow HTTP traffic (Port 80)
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from all IPs
  }

  # Allow HTTPS traffic (Port 443)
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from all IPs
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow to all destinations
  }

  tags = {
    Name = "ECS-Security-Group" # Tag the security group
  }
}

# ECS Task Definition to run a container on Fargate
resource "aws_ecs_task_definition" "fargate_task" {
  family                   = "fargate-task"                           # Task family name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # Role for ECS task execution
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn # Role for ECS task
  network_mode             = "awsvpc"                                 # Use awsvpc mode for networking
  requires_compatibilities = ["FARGATE"]                              # Ensure compatibility with Fargate
  cpu                      = "256"                                    # Assign CPU units
  memory                   = "512"                                    # Assign memory in MiB

  # Define the container inside the task
  container_definitions = jsonencode([{
    name      = "my-container" # Name of the container
    image     = "nginx:latest" # Using Nginx image for demo
    essential = true           # Mark container as essential
    portMappings = [
      {
        containerPort = 80    # Map port 80 on container to host
        hostPort      = 80    # Map port 80 on host to container
        protocol      = "tcp" # Use TCP protocol
      }
    ]
    logConfiguration = {
      logDriver = "awslogs" # Use CloudWatch Logs for logging
      options = {
        "awslogs-group"         = "/ecs/fargate-service-logs" # Log group name
        "awslogs-region"        = "us-east-1"                 # AWS region for logs
        "awslogs-stream-prefix" = "ecs"                       # Prefix for log streams
      }
    }
  }])
}

# Create a CloudWatch log group for ECS task logs
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/fargate-service-logs" # Log group name

  retention_in_days = 7 # Retain logs for 7 days (can be adjusted)
}

# ECS Service to run the task on Fargate

resource "aws_ecs_service" "fargate_service" {
  name            = "fargate-service"                        # Name the ECS service
  cluster         = aws_ecs_cluster.ecs_cluster.id           # ECS cluster ID
  task_definition = aws_ecs_task_definition.fargate_task.arn # Task definition ARN
  desired_count   = 1                                        # Run one instance of the task
  launch_type     = "FARGATE"                                # Use Fargate launch type

  # Define network configuration for the ECS service
  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]              # Use the public subnet
    security_groups  = [aws_security_group.ecs_security_group.id] # Attach the ECS security group
    assign_public_ip = true                                       # Assign public IP to tasks
  }                                                               # <-- Closing brace for the network_configuration block

  tags = {
    Name = "Fargate-Service" # Tag the ECS service
  }
}
