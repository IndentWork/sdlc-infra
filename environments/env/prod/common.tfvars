# Common values shared between shared and dedicated scopes — prod environment.
# Loaded first by the pipeline. shared.tfvars or {resource_code}.tfvars can override any value here.
# NOT used by base scope — base has its own base.tfvars.

env       = "prod"
location  = "centralindia"
tenant_id = "8b574092-a70d-49ac-89dc-d754d40b400d"

# Default PostgreSQL SKU — larger than dev. Dedicated tenants can override further.
sku_name = "GP_Standard_D2s_v3"

tags = {
  environment = "prod"
  project     = "sdlc-platform"
  managed_by  = "terraform"
}
