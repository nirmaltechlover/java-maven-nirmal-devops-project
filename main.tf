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

    description = "HTTPS access"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}





resource "aws_instance" "nirmal_instance" {

  ami = var.ami_id

  instance_type = var.instance_type

  key_name = var.key_name

  subnet_id = aws_subnet.nirmal_pubsubnet.id

  vpc_security_group_ids = [aws_security_group.nirmal_sg.id]



  tags = {

    Name = var.env_instance

  }

}



output "aws_ec2_ip" {

    value = aws_instance.nirmal_instance.public_ip
}


