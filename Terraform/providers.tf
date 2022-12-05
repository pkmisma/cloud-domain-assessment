provider "aws" {
  region = lookup(var.awsprops, "region")
}