# terraform-aws-labels-demo

This module demonstrates the usage of [terraform-aws-labels](https://github.com/clouddrove/terraform-aws-labels) to
provide a consistent naming and tagging convention for all infrastructure resources deployed into AWS accounts.

Why is it so important to have a consistent naming and tagging convention?

It comes with the following benefits:

- Consistent naming and tagging makes resource administration easier. It outlines type, purpose and ownership of the resource and tells us in which environment and project it gets consumed.
- It also helps us to react to security incidents by instantly scoping environment and affected project.
- Tracking costs by project or owner can also be easily supported.

Automation helps here to have all resources named and tagged in a standardized way.

We suggest to use the [terraform-aws-label]( https://github.com/clouddrove/terraform-aws-labels) Terraform module from
CloudDrove in all your projects.
It does not deploy any additional resource into your account but offers a collection of variables as outputs
that can be used in your deployment modules.

Here is the list of exported variables:

- attributes: (optional) additional name parts for the "id", e.g. can be applied to distinguish by version or by team
- environment: usually taken from the terraform workspace (e.g. "dev", "qa", "prod")
- id: disambiguated "id" composed of "name", "environment" and "attributes"
- label_order: defines whether "id" starts with the "name" or "environment"
- name: your project name
- repository: URL of the repository of your project
- tags: key/value pairs generated from your input to the module ("Name", "Environment", "ManagedBy", "Repository" and extra tags you might have added).

*Note: These module outputs can also be passed to other layers of configuration files using "terraform_remote_state".*

The most important outputs are "id" and "tags".

You would usually use "id" as a prefix when you set your resource names to group resources together around project name and environment.

And "tags" can be automatically assigned to all your project resources in your provider setup.

## Scenarios

### Example setting up name and default tags using `terraform-aws-labels`

```terraform
labels.tf:

module "labels" {
  source = "git::https://github.com/clouddrove/terraform-aws-labels.git?ref=tags/1.3.0"

  delimiter = "-" # to separate "name", "environment" and "attributes" in "id"

  label_order = ["name", "environment"] # determines sequence of "name" and "environment in "id"; here it is "name"-"environment"-"attributes"

  # These key-value pairs are getting exported as part of "tags"
  attributes  = ["v1"] # concatenated attributes are automatically added to "id"
  environment = terraform.workspace
  managedby   = "my-github-name"
  name        = "my_project"
  repository  = "https://github.com/clouddrove/terraform-aws-labels" # change it to your project repo url!

  # These key-value pairs are getting exported as part of "tags"
  extra_tags = {
    Application  = "my_application",
    BusinessUnit = "my_business_unit",
    Contact      = "first_name.last_name@company.com",
    CostCenter   = "my_cost_center",
    CustomerCode = "123",
    DeployedBy   = "first_name.last_name@company.com",
    Purpose      = "Product Level-OE",
  }
}

main.tf:

resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = join("-", [module.labels.id, "vpc1"])
  }
}

outputs.tf:

output "labels" {
  value = module.labels
}

output "vpc1" {
  value = resource.aws_vpc.vpc1
}

versions.tf:

terraform {
  required_version = "~> 1.0"
  backend "local" {}
}

provider "aws" {
  default_tags {
    tags = module.labels.tags
  }
}
```

Outputs that get exported when we deploy into a `dev` environment:

```terraform
labels = {
  "attributes" = "v1"
  "environment" = "dev"
  "id" = "my_project-dev-v1"
  "label_order" = tolist([
    "name",
    "environment",
  ])
  "name" = "my_project"
  "repository" = "https://github.com/clouddrove/terraform-aws-labels"
  "tags" = {
    "Application" = "my_application"
    "BusinessUnit" = "my_business_unit"
    "Contact" = "first_name.last_name@company.com"
    "CostCenter" = "my_cost_center"
    "CustomerCode" = "123"
    "DeployedBy" = "first_name.last_name@company.com"
    "Environment" = "dev"
    "Managedby" = "my-github-name"
    "Name" = "my_project-dev-v1"
    "Purpose" = "Product Level-OE"
    "Repository" = "https://github.com/clouddrove/terraform-aws-labels"
  }
}

vpc1 = {
  "arn" = "arn:aws:ec2:eu-central-1:094033154904:vpc/vpc-0b58eb434766940af"
  "assign_generated_ipv6_cidr_block" = false
  "cidr_block" = "10.0.0.0/16"
  "default_network_acl_id" = "acl-0f7b64dfbfff60173"
  "default_route_table_id" = "rtb-0372a735148df276f"
  "default_security_group_id" = "sg-0cd8531aa9de50f9c"
  "dhcp_options_id" = "dopt-ff739395"
  "enable_classiclink" = false
  "enable_classiclink_dns_support" = false
  "enable_dns_hostnames" = false
  "enable_dns_support" = true
  "enable_network_address_usage_metrics" = false
  "id" = "vpc-0b58eb434766940af"
  "instance_tenancy" = "default"
  "ipv4_ipam_pool_id" = tostring(null)
  "ipv4_netmask_length" = tonumber(null)
  "ipv6_association_id" = ""
  "ipv6_cidr_block" = ""
  "ipv6_cidr_block_network_border_group" = ""
  "ipv6_ipam_pool_id" = ""
  "ipv6_netmask_length" = 0
  "main_route_table_id" = "rtb-0372a735148df276f"
  "owner_id" = "094033154904"
  "tags" = tomap({
    "Name" = "my_project-dev-v1-vpc1"
  })
  "tags_all" = tomap({
    "Application" = "my_application"
    "BusinessUnit" = "my_business_unit"
    "Contact" = "first_name.last_name@company.com"
    "CostCenter" = "my_cost_center"
    "CustomerCode" = "123"
    "DeployedBy" = "first_name.last_name@company.com"
    "Environment" = "dev"
    "Managedby" = "my-github-name"
    "Name" = "my_project-dev-v1-vpc1"
    "Purpose" = "Product Level-OE"
    "Repository" = "https://github.com/clouddrove/terraform-aws-labels"
  })
}
```
