# Common values shared between shared and dedicated scopes — dev environment.
# Loaded first by the pipeline. shared.tfvars or {resource_code}.tfvars can override any value here.
# NOT used by base scope — base has its own base.tfvars.

env       = "dev"
location  = "centralindia"
tenant_id = "8b574092-a70d-49ac-89dc-d754d40b400d"

# Default PostgreSQL SKU — dedicated tenants can override with a larger SKU.
sku_name = "B_Standard_B1ms"

tags = {
  environment = "dev"
  project     = "sdlc-platform"
  managed_by  = "terraform"
}
