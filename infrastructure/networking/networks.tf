data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "appvpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "appvpc"
  }
}

resource "aws_internet_gateway" "app_gw" {
  vpc_id = resource.aws_vpc.appvpc.id

  tags = {
    Name = "app_gw"
  }

}



resource "aws_route_table" "app_rt_public" {
  vpc_id = resource.aws_vpc.appvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = resource.aws_internet_gateway.app_gw.id
  }

  tags = {
    Name = "app_rt_public"
  }
}

resource "aws_subnet" "app_public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.appvpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.appvpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "app_public_subnet"
  }
}

resource "aws_route_table_association" "app_public_subnet_assoc" {
  count          = 2
  subnet_id      = element(aws_subnet.app_public.*.id, count.index)
  route_table_id = element(aws_route_table.app_rt_public.*.id, count.index)
}

resource "aws_security_group" "app_ecs_task_sg" {
  name   = "app_ecs_task_sg"
  vpc_id = aws_vpc.appvpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}