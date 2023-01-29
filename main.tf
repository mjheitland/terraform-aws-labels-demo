resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = join("-", [module.labels.id, "vpc1"])
  }
}
