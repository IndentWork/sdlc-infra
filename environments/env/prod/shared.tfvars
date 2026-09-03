# Shared scope overrides — prod environment.
# Loaded after common.tfvars. Any value here overrides the common default.
# Used with: -var-file=common.tfvars -var-file=shared.tfvars -backend-config="key=shared.tfstate"

vnet_cidr            = "10.1.0.0/16"
endpoint_subnet_cidr = "10.1.1.0/24"

tags = {
  environment = "prod"
  project     = "sdlc-platform"
  managed_by  = "terraform"
}
