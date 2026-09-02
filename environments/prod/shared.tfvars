# Shared scope — prod environment values.
# Used with: terraform apply -var-file=environments/prod/shared.tfvars -backend-config="key=shared.tfstate"

env       = "prod"
location  = "centralindia"
tenant_id = "8b574092-a70d-49ac-89dc-d754d40b400d"

tags = {
  environment = "prod"
  project     = "sdlc-platform"
  managed_by  = "terraform"
  scope       = "shared"
}
