# Non-sensitive environment values — committed to git.
# Terraform loads *.auto.tfvars automatically — no -var-file flag needed.
# Sensitive values (subscription_id) come from ARM_* environment variables set by the pipeline.

env       = "dev"
location  = "centralindia"
tenant_id = "8b574092-a70d-49ac-89dc-d754d40b400d"

tags = {
  environment = "dev"
  project     = "sdlc-platform"
  managed_by  = "terraform"
}
