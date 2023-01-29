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
