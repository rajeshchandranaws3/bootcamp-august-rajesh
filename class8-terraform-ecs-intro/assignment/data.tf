data "aws_ami" "ubuntu_linux" {
  most_recent = true
  filter {
    name   = "image-id"
    values = ["ami-0360c520857e3138f"]
  }
  owners = ["amazon"]
}

data "aws_region" "current" {

}