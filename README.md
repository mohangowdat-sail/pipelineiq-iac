# PipelineIQ — Infrastructure as Code

Terraform + Bicep for every Azure resource in the PipelineIQ platform.

This repo is the **single source of truth for infrastructure**. Any
resource not defined here is either legacy (to be migrated) or drift (to
be reconciled or destroyed). Nothing gets clicked into the Azure portal.

Companion repos:
- `PipelineIQ-Architecture/` — application code, pipelines, docs,
  decisions. Start there if you are new to PipelineIQ.
- `PipelineIQ-Portal/` — React dashboard, hosted on Vercel.

---

## Layout

```
core/                     Reusable core modules (RG, Key Vault, ADLS, Log
                          Analytics, managed identities, Databricks,
                          PostgreSQL, OpenAI, Container Apps). Stable —
                          do not modify without reason.

source_connectors/        One module per source system type.
  azure_sql/              Used by Velora.
  blob_storage/           Stub — future file-drop clients.
  http_api/               Stub — future REST API clients.
  eventhub/               Stub — future streaming clients.

clients/                  Composition roots. One folder per client.
  velora/                 Wires core + source_connectors/azure_sql for
                          Velora Retail. Contains backend.tf, providers.tf,
                          main.tf, variables.tf, terraform.tfvars (gitignored).

pipelineiq_app/           PipelineIQ platform's own infrastructure — the
                          pieces of the SaaS platform itself, not the
                          client-data side. FastAPI Container App,
                          Azure Functions, Static Web Apps binding.

bicep/                    Bicep modules. Used where Bicep is a more
                          natural fit than Terraform.
  adf/                    ADF linked services, datasets, pipelines.

scripts/                  Plan/apply wrappers, auth helpers, module
                          scaffolds.
```

---

## Prerequisites

- Terraform >= 1.6 (pinned via `.terraform-version`)
- Azure CLI logged in to the target subscription
- State backend already bootstrapped — see
  `../PipelineIQ-Architecture/scripts/bootstrap_state.sh`

Current state backend (shared across all clients):
- Resource group: `pipelineiq-rg-dev`
- Storage account: `pipelineiqtfstate`
- Container: `tfstate`
- State key per client: `{client}.tfstate` (e.g. `velora.tfstate`)

---

## Workflow

```bash
# From clients/velora/
terraform fmt -recursive
terraform init              # Once per workspace
terraform validate
terraform plan -out=tfplan  # Review before applying
terraform apply tfplan      # Apply the exact plan you reviewed
```

Never `terraform apply` without a saved plan. Never edit state directly.

---

## Module stability

| Module | Status | Rule |
|---|---|---|
| core/ | Stable | Changes require an entry in ../PipelineIQ-Architecture/DECISIONS.md |
| source_connectors/azure_sql/ | Stable | Velora source — change with care |
| source_connectors/*/ (stubs) | Unbuilt | Scaffold only; build when a new client needs them |
| clients/velora/ | Config | Safe to update variables, module versions |
| pipelineiq_app/ | In progress | Built alongside Phases 2–6 |
| bicep/adf/ | In progress | Built alongside Phase 2 |

---

## Region strategy

All resources in **Central India** except Azure OpenAI, which lives in
**South India** (Central India does not host Azure OpenAI).
See `../PipelineIQ-Architecture/DECISIONS.md` entries #10 and #25.
