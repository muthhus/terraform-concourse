terraform {
  required_version = ">= 0.9.0"

  backend "s3" {
    bucket     = "skyscraperstest-terraform"
    key        = "concourse/main"
    region     = "eu-west-1"
    encrypt    = true
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

module "vpc" {
  source = "github.com/skyscrapers/terraform-network//vpc?ref=2.0.0"

  cidr_block  = "${var.cidr_block["${terraform.env}"]}"
  project     = "${var.project}"
  environment = "${terraform.env}"
}

module "general_security_groups" {
  source      = "github.com/skyscrapers/terraform-network//securitygroups?ref=2.0.0"
  vpc_id      = "${module.vpc.vpc_id}"
  project     = "${var.project}"
  environment = "${terraform.env}"
}

module "nat" {
  source               = "github.com/skyscrapers/terraform-network//nat_gateway?ref=2.0.0"
  private_route_tables = "${module.vpc.private_rts}"
  public_subnets       = "${module.vpc.public_nat-bastion}"
}

module "postgres" {
  source                   = "github.com/skyscrapers/terraform-rds//rds?ref=1.0.0"
  vpc_id                   = "${module.vpc.vpc_id}"
  subnets                  = "${module.vpc.private_db_subnets}"
  project                  = "${var.project}"
  environment              = "${terraform.env}"
  size                     = "db.t2.micro"
  security_groups          = ["${aws_security_group.sg_ecs_instance.id}"]
  rds_password             = "concoursetest"
  multi_az                 = false
  rds_parameter_group_name = "postgres-rds-${var.project}-${terraform.env}"
  rds_type = "postgres"
  storage_encrypted = false
}
