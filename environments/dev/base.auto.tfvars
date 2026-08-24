# Non-sensitive environment values — committed to git.
# Terraform loads *.auto.tfvars automatically — no -var-file flag needed.
# Sensitive values (subscription_id) come from ARM_* environment variables set by the pipeline.

env      = "dev"
location = "centralindia"

tags = {
  environment = "dev"
  project     = "sdlc-platform"
  managed_by  = "terraform"
}
