# CustomCCP - Amplify Deployment Architecture

## Overview

This project uses **Terraform** to automate the deployment of a **React app** (`customccp-ui`) through **AWS Amplify**, triggered via **GitHub Actions**.

## Architecture Flow

GitHub (customccp-ui Repo)
    └── GitHub Actions Workflow (Terraform Apply)
         └── Terraform Backend (State in S3)
              └── AWS Amplify App (customccp-ui)
                   └── AWS Amplify Branch (main)
                        └── Amplify Deployment (npm ci + npm run build)
                             └── Hosted Static App (https://dev.ccp.eastghats.com)

## Deployment Flow

1. React Code pushed to `customccp-ui` GitHub repository (branch `main`).
2. GitHub Actions workflow detects the push event.
3. Terraform initializes and applies:
   - Creates/updates an AWS Amplify app.
   - Connects to GitHub repo.
   - Sets environment variables.
   - Sets proper rewrites and redirects.
   - Creates branch, connects to `main` branch.
   - Associates domain `dev.ccp.eastghats.com`.
4. Amplify Build runs:
   - `npm ci --cache .npm --prefer-offline`
   - `npm run build`
5. Amplify Hosting deploys `/build` folder as a static website.
6. App becomes publicly available at `https://dev.ccp.eastghats.com`

## Terraform Module Structure

Path | Purpose
--- | ---
`envs/dev/main.tf` | Dev environment setup (Amplify App, API Gateway, Lambda, IAM).
`modules/amplify/main.tf` | Amplify App, Branch, Domain Association resources.
`modules/amplify/buildspec.yml` | Build instructions for React app.
`modules/amplify/outputs.tf` | Amplify outputs (App ID, URL).
`modules/amplify/variables.tf` | Amplify input variables.

## Important Configurations

### Buildspec

version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm ci --cache .npm --prefer-offline
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: build
    files:
      - '**/*'
  cache:
    paths:
      - .npm/**/*

### Rewrites and Redirects

Source | Target | Status
--- | --- | ---
/<*> | /index.html | 404-200
</^[^.]+$|\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|ttf|map|json)$)([^.]+$)/> | /index.html | 200

These ensure proper SPA routing.

### Environment Variables

REACT_APP_REGION         = "eu-west-2"
REACT_APP_CCP_URL        = "https://eastghats-dev.awsapps.com/connect/ccp-v2/"
REACT_APP_API_BASE_URL   = "https://{API-Gateway-URL}"

### Domain Mapping

Custom Domain | Amplify Subdomain
--- | ---
dev.ccp.eastghats.com | main branch hosting

## GitHub Actions CI/CD Pipeline

- On push to `dev` branch in Infra repo:
  - Terraform init.
  - Terraform apply.
  - Deploy Amplify app automatically.

name: Deploy DEV

on:
  push:
    branches: [ dev ]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Configure AWS credentials using OIDC
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::306461035734:role/GitHubActionsCustomCcpRole
          aws-region: eu-west-2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        working-directory: ./envs/dev
        run: |
          terraform init \
            -backend-config="bucket=eastghats-ccp-terraform-state-dev" \
            -backend-config="key=dev/terraform.tfstate" \
            -backend-config="region=eu-west-2"

      - name: Terraform Apply
        working-directory: ./envs/dev
        env:
          TF_VAR_github_token: ${{ secrets.TF_VAR_github_token }}
        run: terraform apply -auto-approve

## Final Notes

- Destroy/Recreate strategy is needed if repository URL, branch, or major app settings change.
- Terraform state is safely stored in S3 (`eastghats-ccp-terraform-state-dev` bucket).
- Secrets like GitHub token are securely passed via GitHub Secrets (OIDC).

## Deployment Result

You will see your React app fully working on Amplify without the `Unexpected token <` error.

Hosted URL Example:
https://dev.ccp.eastghats.com

# Contact for Support
- Project: CustomCCP
- Maintained by: Eastghats Team

