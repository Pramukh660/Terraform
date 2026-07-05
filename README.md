# FastAPI Infrastructure Deployment using Terraform + floci-az + GHCR

This project demonstrates a complete Infrastructure as Code (IaC) workflow for deploying a containerized FastAPI application using **Terraform**, **Docker**, **GitHub Container Registry (GHCR)**, and **floci-az** (Azure emulator).

The goal is to provision Azure resources locally, automatically deploy a Dockerized FastAPI application from GHCR, and configure the VM using **cloud-init**.

---

# Architecture

```text
                    +-------------------------+
                    |   GitHub Repository     |
                    +------------+------------+
                                 |
                                 |
                                 | GitHub Actions (Optional)
                                 |
                                 v
                    +-------------------------+
                    |  GitHub Container       |
                    |  Registry (GHCR)        |
                    +------------+------------+
                                 |
                                 |
                                 |
                Terraform + Cloud-init
                                 |
                                 v
        +------------------------------------------------+
        |              floci-az (Azure Emulator)          |
        |------------------------------------------------|
        | Resource Group                                 |
        | Virtual Network                                |
        | Network Security Group                         |
        | Public IP                                      |
        | Network Interface                              |
        | Linux Virtual Machine                          |
        +----------------------+-------------------------+
                               |
                               |
                               | cloud-init
                               |
                               v
                      Ubuntu Virtual Machine
                               |
                               |
                      Install Docker Engine
                               |
                               |
                      Login to GHCR
                               |
                               |
                      Pull Docker Image
                               |
                               |
                 Run FastAPI Container (7011)
                               |
                               |
                               v
                      FastAPI Application
```

---

# Tech Stack

- FastAPI
- Docker
- Terraform
- AzureRM Provider
- floci-az
- GitHub Container Registry (GHCR)
- Cloud-init
- Ubuntu 24.04

---

# Project Structure

```text
.
├── app/
├── Dockerfile
├── requirements.txt
├── .env
├── terraform/
│   ├── providers.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── main.tf
│   ├── resource-group.tf
│   ├── network.tf
│   ├── nsg.tf
│   ├── vm.tf
│   ├── outputs.tf
│   └── cloud-init.yaml.tftpl
└── README.md
```

---

# Docker Image

Dockerfile used for the application:

```dockerfile
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 7011

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7011"]
```

Build the image:

```bash
docker build -t archeone-travel .
```

Run locally:

```bash
docker run -p 7011:7011 archeone-travel
```

---

# Push Image to GHCR

Login

```bash
echo <GITHUB_PAT> | docker login ghcr.io -u <github-username> --password-stdin
```

Tag

```bash
docker tag archeone-travel ghcr.io/<github-username>/archeone-travel:latest
```

Push

```bash
docker push ghcr.io/<github-username>/archeone-travel:latest
```

---

# Terraform Resources

Terraform provisions:

- Resource Group
- Virtual Network
- Subnet
- Public IP
- Network Security Group
- Network Interface
- Ubuntu Linux VM

---

# Cloud-init Responsibilities

During VM provisioning, cloud-init performs the following:

- Install Docker
- Enable Docker service
- Login to GHCR
- Pull latest Docker image
- Create application `.env`
- Start FastAPI container
- Configure restart policy

---

# Environment Variables

The application environment file is injected into Terraform at runtime instead of storing it in Git.

Linux

```bash
export TF_VAR_app_env="$(cat ../.env)"
```

PowerShell

```powershell
$env:TF_VAR_app_env = Get-Content ..\.env -Raw
```

---

# Terraform Provider

Example provider configuration:

```hcl
provider "azurerm" {
  features {}

  skip_provider_registration = true
  use_cli                    = false

  environment   = "stack"
  metadata_host = "localhost:4577"

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}
```

---

# Running floci-az

```bash
docker run -d \
  --name floci-az \
  -p 4577:4577 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/data:/app/data \
  -e FLOCI_AZ_TLS_ENABLED=true \
  floci/floci-az:latest
```

Download TLS certificate

```bash
curl http://localhost:4577/_floci/tls-cert -o floci-az.crt
```

Trust certificate (Ubuntu)

```bash
sudo cp floci-az.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

Verify

```bash
curl -k https://localhost:4577/metadata/endpoints
```

---

# Terraform Workflow

Initialize

```bash
terraform init
```

Validate

```bash
terraform validate
```

Format

```bash
terraform fmt
```

Plan

```bash
terraform plan
```

Apply

```bash
terraform apply
```

Destroy

```bash
terraform destroy
```

---

# Networking

Inbound Rules

| Port | Purpose |
|------|----------|
| 22 | SSH |
| 7011 | FastAPI |

Container Mapping

```text
Host Port      : 7011
Container Port : 7011
```

---

# Outputs

Terraform outputs:

- Public IP
- Resource Group
- VM Name
- SSH Command

Example

```bash
terraform output
```

---

# Security Notes

- Do **not** commit `.env` files.
- Do **not** commit GitHub Personal Access Tokens.
- Store secrets securely (Azure Key Vault or GitHub Secrets in production).
- Rotate any credentials that are accidentally exposed.

---

# Current Status

✅ FastAPI Docker image built

✅ Image published to GHCR

✅ Terraform configuration completed

✅ Azure resources provisioned through floci-az

✅ cloud-init configured

⚠️ Current floci-az versions emulate Azure Resource Manager resources successfully. VM guest execution (SSH/cloud-init runtime) may depend on the emulator's compute support and configuration.

---

# Future Improvements

- GitHub Actions CI/CD
- Azure Key Vault integration
- Managed Identity authentication
- HTTPS with Nginx reverse proxy
- Custom domain
- Monitoring and logging
- Health checks
- Docker Compose deployment
- Azure Container Registry support
- Auto-scaling on real Azure

---

# References

- https://developer.hashicorp.com/terraform
- https://fastapi.tiangolo.com/
- https://docs.docker.com/
- https://docs.github.com/packages/working-with-a-github-packages-registry/working-with-the-container-registry
- https://cloudinit.readthedocs.io/
