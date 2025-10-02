# Private ec2
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private1.id
  availability_zone      = aws_subnet.private1.availability_zone
  vpc_security_group_ids = [aws_security_group.ssh_sg.id, ]
  key_name               = "my-vpc-key"
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-ec2" })
  )
}

# Public ec2
resource "aws_instance" "public" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id, ]
  key_name               = "my-vpc-key"
  availability_zone      = aws_subnet.public.availability_zone

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-ec2" })
  )
}

# Security Group for SSH Access to EC2 Instances
resource "aws_security_group" "ssh_sg" {

  description = "allow ssh to ec2"
  name        = "${local.prefix}-ssh_access"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.vpc_cidr]
    #We can limit the ip here
  }
  tags = local.common_tags

}
