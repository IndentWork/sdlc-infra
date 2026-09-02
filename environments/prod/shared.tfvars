# Shared scope overrides — prod environment.
# Loaded after common.tfvars. Any value here overrides the common default.
# Used with: -var-file=common.tfvars -var-file=shared.tfvars -backend-config="key=shared.tfstate"

tags = {
  environment = "prod"
  project     = "sdlc-platform"
  managed_by  = "terraform"
  scope       = "shared"
}
