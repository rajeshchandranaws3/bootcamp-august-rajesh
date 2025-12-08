<!-- .github/copilot-instructions.md: Guidance for AI coding agents working in this repository -->
# Copilot / AI Agent Instructions

This repository is a DevOps bootcamp with multiple class folders. Agents should prioritize `class13_14-ecs-tf-gh-advanced` and top-level `infra/` and `app/` folders because they contain the primary end-to-end example (Flask + Celery app deployed to ECS via Terraform).

- **Big picture:**
  - **App layer:** `class13_14-ecs-tf-gh-advanced/app` — a Flask application with Celery tasks and Flask-Mail. It includes `Dockerfile`, `run.sh` (starts gunicorn and celery), Nginx config under `app/nginx`, and SQLAlchemy models in `app/models.py`.
  - **Infra layer:** `class13_14-ecs-tf-gh-advanced/infra` — Terraform code that provisions ECR, ECS, ALB, RDS, CloudWatch and Route53. Task definitions are templates in `infra/task-definitions/*.json.tpl` and populated by Terraform variables.
  - **Training folders:** many `class*` directories contain exercises; prefer not to change them unless asked.

- **Why this structure matters:**
  - The repo is instructional: changes should avoid breaking example flows (e.g., `infra/vars/*` used in Terraform commands). Many files are templates (e.g., `*.json.tpl`) — do not hardcode cloud values there.

- **Key developer workflows & commands** (executable in workspace root or respective folders):
  - Build and run Flask app locally (from `class13_14-ecs-tf-gh-advanced/app`):
    - `docker build -t dojo-app .` (uses `app/Dockerfile`)
    - `./run.sh` starts `gunicorn` and `celery` (development helper).
  - Run docker-compose locally: `docker-compose up` in `class13_14-ecs-tf-gh-advanced/app` (there is a `docker-compose.yml`).
  - Terraform (in `class13_14-ecs-tf-gh-advanced/infra`):
    - Dev: `terraform init -backend-config=vars/dev.tfbackend && terraform plan -var-file=vars/dev.tfvars && terraform apply -var-file=vars/dev.tfvars`
    - Prod: same with `vars/prod.tfbackend` and `vars/prod.tfvars` (see `infra/readme.md`).

- **Important patterns & conventions (repo-specific)**
  - Environment variables are used heavily for secrets/config in templates and app: examples include `MAIL_USERNAME`, `MAIL_PASSWORD`, `CELERY_BROKER_URL`, and DB env vars like `POSTGRES_PASSWORD` (refer `app/app.py` and `infra/task-definitions/flask-service.json.tpl`).
  - Task definition templates use `${...}` placeholders filled by Terraform; treat these as template files, not runnable JSON directly.
  - `run.sh` is used as the entrypoint for local dev to run both web and worker processes; CI or deployed containers use individual processes (gunicorn, celery) managed by ECS task definitions.

- **Files to inspect first when asked about functionality or bugs**
  - `class13_14-ecs-tf-gh-advanced/app/app.py` — web routes, Celery tasks, and mail/celery initialization.
  - `class13_14-ecs-tf-gh-advanced/app/Dockerfile` and `app/nginx/*` — containerization and local web proxy behavior.
  - `class13_14-ecs-tf-gh-advanced/app/run.sh` — how the app starts in local mode.
  - `class13_14-ecs-tf-gh-advanced/infra/readme.md` and `infra/*.tf` — terraform usage and variable files (`infra/vars/*`).
  - `class13_14-ecs-tf-gh-advanced/infra/task-definitions/*.json.tpl` — how environment variables and images are wired into ECS tasks.

- **How to make safe code changes**
  - Prefer small, local edits to application code (e.g., fix a Flask route) and include a short test/invocation to verify behavior.
  - Do not modify Terraform backend or tfvars files without explicit confirmation — these files map to example accounts/backends used during teaching.
  - When changing template variables, update the corresponding `vars/*.tfvars` or document how the template is populated.

- **Examples to cite in PRs or suggestions**
  - If suggesting an env var default, reference `app/app.py` lines where `os.environ.get('MAIL_USERNAME')` and `CELERY_BROKER_URL` are read.
  - If suggesting container changes, point to `app/Dockerfile` and `app/run.sh` for current runtime behavior.
  - For infra changes, reference `infra/readme.md` and `infra/task-definitions/*` to show how Terraform expects templates and variables.

If something is unclear or you want me to expand any subsection (for example: add a short troubleshooting checklist for common Terraform errors or a simple local `make` target set), tell me which area to expand and I will iterate.
