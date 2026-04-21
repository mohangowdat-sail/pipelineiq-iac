# PipelineIQ-IaC — Claude Context

This file is the anchor for any Claude Code session working in the
infrastructure repo. Read this first, every session.

The **architectural source of truth** lives in the companion repo:
`../PipelineIQ-Architecture/`. Before doing anything non-trivial here,
read:

- `../PipelineIQ-Architecture/CLAUDE.md` — full project contract
- `../PipelineIQ-Architecture/PLANNING.md` — architecture rationale
- `../PipelineIQ-Architecture/DECISIONS.md` — every architectural choice
- `../PipelineIQ-Architecture/docs/build_order.md` — dependency-ordered
  build tracker. Update this file as resources land.
- `../PipelineIQ-Architecture/PROGRESS.md` — phase status + session log

This repo's job is to encode those decisions as Terraform + Bicep.
Never invent architecture here. If you find yourself about to make a
non-trivial design choice, stop and record it in `DECISIONS.md` in the
Architecture repo before writing HCL.

---

## Hard rules for this repo

1. **State is sacred.** Never `terraform apply` without a saved
   `-out=tfplan`. Never edit `terraform.tfstate` by hand. Never delete
   or recreate the state container.
2. **No portal-clicking.** Every resource in Azure must trace back to
   a file in this repo. If you discover drift, reconcile or destroy —
   do not rubber-stamp portal changes into code without an entry in
   DECISIONS.md.
3. **Secrets never land in git.** `terraform.tfvars` is gitignored.
   All secrets go through Key Vault. `*.tfvars.example` files are
   committed; real `*.tfvars` are not.
4. **`core/` is stable.** Changes to resources in `core/` require an
   explicit entry in `../PipelineIQ-Architecture/DECISIONS.md` with
   rationale. Do not refactor core modules opportunistically.
5. **Tag everything.** Every resource carries the four standard tags:
   `project = "pipelineiq"`, `environment`, `owner = "data-engineering"`,
   `managed_by = "terraform"`.
6. **Module outputs are contracts.** Once an output is consumed by
   another module, changing its name or shape is a breaking change.

---

## Repo layout

```
core/                   Reusable per-service modules
source_connectors/      Per-source-type modules
  azure_sql/            (Velora)
  blob_storage/         (stub)
  http_api/             (stub)
  eventhub/             (stub)
clients/                Per-client compositions — `terraform apply` runs here
  velora/
pipelineiq_app/         PipelineIQ's own platform infra (not client data)
bicep/adf/              Bicep for ADF pipelines
scripts/                Helpers
```

---

## Naming and tags

All resources: `pipelineiq-{component}-{environment}`.
Example: `pipelineiq-databricks-dev`, `pipelineiq-adls-dev`.

Required tags on every resource:
```hcl
tags = {
  project     = "pipelineiq"
  environment = var.environment
  owner       = "data-engineering"
  managed_by  = "terraform"
}
```

Enforce via a local map in each module:
```hcl
locals {
  common_tags = {
    project     = "pipelineiq"
    environment = var.environment
    owner       = "data-engineering"
    managed_by  = "terraform"
  }
}
```

---

## Region strategy

| Resource | Region | Reason |
|---|---|---|
| All data / pipeline / compute / control plane | Central India | DECISIONS.md #10 |
| Azure OpenAI | South India | Central India does not host it. DECISIONS.md #25 |

When writing a module that creates OpenAI, accept `var.openai_location`
separately from `var.location` and default it to `southindia`.

---

## State backend

Shared across clients. Bootstrapped once via
`../PipelineIQ-Architecture/scripts/bootstrap_state.sh`.

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "pipelineiq-rg-dev"
    storage_account_name = "pipelineiqtfstate"
    container_name       = "tfstate"
    key                  = "velora.tfstate"   # one key per client
  }
}
```

---

## Session discipline

Mirror the Architecture repo's session discipline:

- ONE OBJECTIVE per session. State it explicitly at the start.
- COMMIT after every meaningful chunk. Push frequently — the IaC change
  webhook relies on main-branch commits landing in real time.
- UPDATE `../PipelineIQ-Architecture/docs/build_order.md` the moment
  any item flips status (Pending → Done, Blocked, etc.).
- UPDATE `../PipelineIQ-Architecture/DECISIONS.md` immediately when any
  architectural choice is made.
- APPEND a session log entry to `../PipelineIQ-Architecture/PROGRESS.md`
  at the end of every session (see format in Architecture CLAUDE.md).

---

## When in doubt

Read the Architecture repo. This repo encodes decisions made there.
If a decision isn't already documented in the Architecture repo,
document it there *before* you write the HCL that implements it.
