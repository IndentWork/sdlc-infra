# sdlc-infra

Terraform infrastructure for the SDLC platform on Azure. Creates every Azure resource — VNets, PostgreSQL, Key Vault, Managed Identity, Container Registry, Container App.

## What it creates (base scope, dev environment)

```
rg-sdlc-base-dev                          Resource group
├── vnet-sdlc-base-dev                    VNet 10.0.0.0/16
│   ├── snet-sdlc-base-dev-postgres       Delegated to PostgreSQL Flexible Server
│   └── snet-sdlc-base-dev-container-app  Delegated to Container Apps
├── kv-sdlc-base-dev                      Key Vault (RBAC, no private endpoint)
├── id-sdlc-base-dev                      Managed Identity for FastAPI
├── psql-sdlc-base-dev                    PostgreSQL 16 with sdlc database
├── crsdlcdev                             Container Registry
├── cae-sdlc-base-dev                     Container App Environment (VNet-integrated)
└── ca-sdlc-base-dev                      FastAPI Container App
```

## Structure

```
sdlc-infra/
├── environments/
│   ├── dev/          Composes modules for dev
│   │   ├── backend.tf         Terraform state in Azure Storage
│   │   ├── base.tf            Wires all base scope modules
│   │   ├── base.auto.tfvars   env, location, tenant_id, tags
│   │   └── variables.tf
│   └── prod/         Same shape as dev (later)
├── modules/          Generic, reusable — take scope + env, build the name
│   ├── resource-group/
│   ├── vnet/
│   ├── keyvault/
│   ├── managed-identity/
│   ├── postgres/
│   ├── container-registry/
│   └── container-app/
└── scripts/
    ├── set_env.sh    Load ARM_* credentials from sdlc_bootstrap/.env
    └── tf.sh         One-liner: source ./scripts/tf.sh dev plan
```

## Running locally

```bash
# Load credentials + run terraform in one command
source ./scripts/tf.sh dev plan
source ./scripts/tf.sh dev apply
source ./scripts/tf.sh dev destroy
```

Requires [`sdlc_bootstrap`](https://github.com/IndentWork/sdlc_bootstrap) to have run first — creates the Terraform SP and populates `.env`.

## Running via pipeline

**Actions → SDLC Infra Terraform → Run workflow → select DEV or PROD**

Flow:
1. `plan` job runs → shows what will change
2. Pauses at the `apply` GitHub environment (manual approval)
3. On approval, `apply` job runs the same plan file

**Actions → SDLC Infra Destroy → Run workflow → select DEV or PROD** — same pattern for destroy.

## Naming convention

All resources: `{prefix}-sdlc-{scope}-{env}` — hardcoded in each module.

Scope values:
- `base` — management plane (FastAPI, PostgreSQL, Key Vault)
- `shared` — resources for shared-tier tenants
- `<org_code>` — one dedicated tenant

## State backend

Azure Storage in `rg-sdlc-terraform-{env}` (created by `sdlc_bootstrap`):

- Storage account: `stsdlcindent{env}`
- Container: `tfstate`
- Key: `{env}.tfstate`

## Adding a new module

1. Create `modules/<name>/{main,variables,outputs}.tf`
2. Use `scope` + `env` variables — never hardcode dev/prod
3. Call it from `environments/dev/base.tf` (or `shared.tf` / `private.tf`)
4. `source ./scripts/tf.sh dev plan` to verify
