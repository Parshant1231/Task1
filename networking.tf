data "aws_availability_zones" "available" {}


# Subnets for public, private , db surfaces
resource "aws_subnet" "public" {
    count = 2

    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnet_cidrs[count.index]
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "${local.name_prefix}-public-${count.index + 1}"
    }
}

resource "aws_subnet" "private_app" {
    count = 2

    vpc_id             = aws_vpc.main.id
    cidr_block         = var.private_app_subnet_cidrs[count.index]
    availability_zone  = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "${local.name_prefix}-private-app-${count.index + 1}"
    }
}

resource "aws_subnet" "private_db" {
    count = 2

    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.private_db_subnet_cidrs[count.index]
    availability_zone       = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "${local.name_prefix}-private-db-${count.index + 1}"
    }
}

resource "aws_eip" "nat" {
    count  = 2
    domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
    count = 2

    allocation_id = aws_eip.nat[count.index].id
    subnet_id     = aws_subnet.public[count.index].id
}

# To Create a route_table , route and associate route_table & subnet
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${local.name_prefix}-public-rt"
    }
}

resource "aws_route" "public_internet" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
    count =2

    subnet_id       = aws_subnet.public[count.index].id
    route_table_id  = aws_route_table.public.id
}


# For Private APP

resource "aws_route_table" "private_app" {
    count  = 2

    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${local.name_prefix}-private-app-rt-${count.index + 1}"
    }
}

resource "aws_route" "private_app_nat" {
    count = 2

    route_table_id = aws_route_table.private_app[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_app" {
    count = 2

    subnet_id      = aws_subnet.private_app[count.index].id
    route_table_id = aws_route_table.private_app[count.index].id 
}


# for db

resource "aws_route_table" "private_db" {
    count = 2

    vpc_id = aws_vpc.main.id
    
    tags = {
        Name = "${local.name_prefix}-private-db-rt-${count.index + 1}"
    }
}

resource "aws_route_table_association" "private_db" {
    count = 2

    subnet_id        = aws_subnet.private_db[count.index].id
    route_table_id   = aws_route_table.private_db[count.index].id
}