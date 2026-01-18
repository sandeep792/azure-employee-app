# Azure Employee Directory App

This is a complete solution for an Employee Directory web application hosted on Azure.

## Architecture

- **Frontend**: Single Page Application (React + Vite)
- **Middle Layer**: Azure Functions (Node.js v4)
- **Database**: Azure Cosmos DB (NoSQL)
- **Infrastructure**: Terraform (Modular)
- **Security**:
  - Private Endpoints for Cosmos DB
  - VNet Integration for Function App
  - Managed Identity for connection between Function and Cosmos DB (Data Plane RBAC)

## Components

### 1. Frontend (`/frontend`)

A modern, responsive SPA built with React.

- **Features**: Searchable employee list, Glassmorphism design, Smooth animations.
- **Local Dev**: `npm run dev` (Runs on port 5173).

### 2. Backend (`/backend`)

Azure Functions acting as the API.

- **Function**: `getEmployees` (HTTP Trigger).
- **Authentication**: Uses `DefaultAzureCredential` to connect to Cosmos DB securely.
- **Local Dev**: `npm start` (Runs on port 7071).

### 3. Infrastructure

Infrastructure as Code (Terraform) is co-located with each component to support independent deployments.

- **Backend Infrastructure** (`backend/IaC`): Provisions global Cosmos DB, Networking, and Function App.
- **Frontend Infrastructure** (`frontend/IaC`): Provisions Storage Account for static website hosting.

## Deployment Instructions

### Prerequisites

- Azure CLI installed and logged in (`az login`).
- Terraform installed.
- Node.js installed.

### 1. Create Azure Service Principal (One-time Setup)

GitHub Actions needs specific permission to create resources in your Azure subscription.
Run this command in your terminal:

```bash
az ad sp create-for-rbac --name "sp-github-actions-employee-app" --role Contributor --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> --json-auth
```

*Copy the entire JSON output.*

### 2. Create Terraform State Storage (One-time Setup)

You must create a Storage Account manually to hold the Terraform state files. Run these commands in your terminal:

1. **Create Resource Group**:

   ```bash
   az group create --name "rg-terraform-state" --location eastus
   ```

2. **Create Storage Account** (Name must be globally unique, e.g., `stemployeeapptfstate`):

   ```bash
   az storage account create --name "stemployeeapptfstate" --resource-group "rg-terraform-state" --location eastus --sku Standard_LRS --encryption-services blob
   ```

3. **Create Blob Container**:

   ```bash
   az storage container create --name "tfstate" --account-name "stemployeeapptfstate"
   ```

### 3. Configure GitHub Secrets

Go to **Settings > Secrets and variables > Actions** in your GitHub repository and add these 3 secrets:

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS` | The JSON output from Step 1 |
| `TF_STATE_RG` | The Resource Group name from Step 2 (`rg-terraform-state`) |
| `TF_STATE_STORAGE_ACCOUNT` | The Storage Account name you created in Step 2 (e.g., `stemployeeapptfstate`) |

### Deployment Steps (GitHub Actions)

Pushing to the `main` branch will deploy to **Production**. Pushing to the `develop` branch will deploy to **Dev**.

### Manual Deployment (Local)

1. **Initialize with Backend**:

   ```bash
   cd backend/IaC
   terraform init \
       -backend-config="resource_group_name=<from-bootstrap>" \
       -backend-config="storage_account_name=<from-bootstrap>" \
       -backend-config="container_name=tfstate" \
       -backend-config="key=backend-dev.tfstate"
   
   terraform apply -var-file="environments/dev.tfvars"
   ```

2. **Deploy Backend**:

   ```bash
   cd ../backend
   npm install
   # Use Azure Functions Core Tools
   func azure functionapp publish <function_app_name>
   ```

3. **Deploy Frontend**
   Build the frontend:

   ```bash
   cd ../frontend
   npm install
   npm run build
   ```

   Deploy the `dist` folder to an Azure Static Web App or Storage Account (not included in Terraform for simplicity, but easily added). Alternatively, serve static files from the Function App (requires config).

## Local Development

1. Start Backend:

   ```bash
   cd backend
   npm start
   ```

2. Start Frontend:

   ```bash
   cd frontend
   npm run dev
   ```

   The frontend proxies `/api` calls to `http://localhost:7071`.

## Security Notes

- The Cosmos DB is only accessible via Private Endpoint (from within the VNet).
- The Function App is integrated into the VNet.
- No access keys are used in the code; Managed Identity is used.
