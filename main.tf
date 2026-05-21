####Provider###############

provider "aws" {

  region = var.aws_region
}


######## VPC ###############
resource "aws_vpc" "nirmal_vpc" {

  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "nirmal_vpc"
  }

}

##### Public_Subnet #########

resource "aws_subnet" "nirmal_pubsubnet" {

  vpc_id = aws_vpc.nirmal_vpc.id

  cidr_block = "192.168.1.0/24"

  map_public_ip_on_launch = true

  tags = {

    Name = "nirmal_public_subnet"
  }

}



####Private_Subnet ##################

resource "aws_subnet" "nirmal_privatesubnet" {

  vpc_id = aws_vpc.nirmal_vpc.id

  cidr_block = "192.168.2.0/24"

  tags = {

    Name = "nirmal_privatesubnet"
  }

}

#######Internet gateway ##############

resource "aws_internet_gateway" "nirmal_igw" {

  vpc_id = aws_vpc.nirmal_vpc.id

  tags = {

    Name = "aws_nirmal_igw"
  }

}



##### Public_Route table #################

resource "aws_route_table" "nirmal_pubroute" {
  vpc_id = aws_vpc.nirmal_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nirmal_igw.id
  }

  tags = {
    Name = "nirmal_pubroute"
  }

}

resource "aws_route_table_association" "pub_ass" {

  subnet_id      = aws_subnet.nirmal_pubsubnet.id
  route_table_id = aws_route_table.nirmal_pubroute.id

}

######Nate gateway#####################

resource "aws_nat_gateway" "nirmal_nat_gatway" {

  allocation_id = aws_eip.nat_eip.id

  subnet_id = aws_subnet.nirmal_pubsubnet.id


  tags = {
    Name = "nirmal_nat_gatway"
  }

  depends_on = [aws_internet_gateway.nirmal_igw]
}

#########Private Route table ##########

resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.nirmal_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.nirmal_nat_gatway.id
  }

  tags = {
    Name = "privateroutetable"
  }
}

resource "aws_route_table_association" "private_ass" {

  subnet_id = aws_subnet.nirmal_privatesubnet.id

  route_table_id = aws_route_table.private_rt.id

}

########EIP #################

resource "aws_eip" "nat_eip" {

  domain = "vpc"

}

#######Security group #############

resource "aws_security_group" "nirmal_sg" {
  name = "nirmal_sg"

  description = "Allow SSH traffic"

  vpc_id = aws_vpc.nirmal_vpc.id

  ingress {

    description = "ssh access"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    description = "HTTP access"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    description = "full_access"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

##########AWS_IAM_ROLE###########
resource "aws_iam_role" "aws_eks_cluster" {

    name = "aws_eks_role"

    assume_role_policy = jsonencode({

        Version = "2012-10-17"

        Statement = [{

        Action =   "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "eks.amazonaws.com"
        }

        }]
       

    })  
}

####AWS_IAM_ROLE_POLICY_ATTACHMENT#############
resource "aws_iam_role_policy_attachment" "aws_eks_cluster_policy" {

      role = aws_iam_role.aws_eks_cluster.name
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  
}

########AWS_IAM_NODE_GROUP_ROLE###############
resource "aws_iam_role" "node_group_role" {
    name = "node_group_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Effect = "Allow"

        Principal = {
            Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
    }]

    }) 
  
}

####AWS_IAM_ROLE_POLICY_ATTACHMENT#############

resource "aws_iam_role_policy_attachment" "node_policy_attachment" {

    role = aws_iam_role.node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

############AWS_NODE_GROUP################
resource "aws_eks_node_group" "aws_eks_node_group" {

    cluster_name = aws_eks_cluster.aws_eks_dev.name

    node_group_name = "aws_eks_worker nodes"

    node_role_arn = aws_iam_role.node_group_role.arn

    subnet_ids = [aws_subnet.nirmal_pubsubnet.id]

    scaling_config {
      desired_size = 2
      min_size = 2

      max_size = 6

    }

    instance_types = ["t3.medium"]
}

##########AWS_EKS_CLUSTER##################

resource "aws_eks_cluster" "aws_eks_dev" {

    name = "aws_eks"

    role_arn = aws_iam_role.aws_eks_cluster.arn

    vpc_config {
     subnet_ids = [aws_subnet.nirmal_pubsubnet.id]
    
     security_group_ids = [aws_security_group.nirmal_sg.id]

  
}

}

########AWS_CNI##########

resource "aws_iam_role_policy_attachment" "cni" {

 role = aws_iam_role.node_group_role.name


 policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"   
  
}


##########AWS_ECR############
resource "aws_iam_role_policy_attachment" "ecr" {

    role = aws_iam_role.node_group_role.name

    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  
}

