# Shared scope — dev environment values.
# Used with: terraform apply -var-file=environments/dev/shared.tfvars -backend-config="key=shared.tfstate"

env       = "dev"
location  = "centralindia"
tenant_id = "8b574092-a70d-49ac-89dc-d754d40b400d"

tags = {
  environment = "dev"
  project     = "sdlc-platform"
  managed_by  = "terraform"
  scope       = "shared"
}
