# Sample dedicated tenant tfvars — copy and rename to {resource_code}.tfvars.
# Each dedicated tenant gets their own file and their own state: {resource_code}.tfstate.
# Used with: -var-file=common.tfvars -var-file={resource_code}.tfvars
#            -backend-config="key={resource_code}.tfstate"

resource_code = "a3f1c2b4"           # SHA256(github_org)[:8] — generated at onboarding

# Each dedicated tenant must use a unique CIDR that does not overlap with:
#   base:   10.0.0.0/16
#   shared: 10.1.0.0/16
# Assign 10.2.0.0/16, 10.3.0.0/16, etc. per tenant.
vnet_cidr            = "10.2.0.0/16"
endpoint_subnet_cidr = "10.2.1.0/24"

tags = {
  environment   = "dev"
  project       = "sdlc-platform"
  managed_by    = "terraform"
  resource_code = "a3f1c2b4"
}
